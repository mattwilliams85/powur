class PayPeriod < ActiveRecord::Base

  has_many :order_totals, dependent: :destroy
  has_many :rank_achievements, dependent: :destroy
  has_many :bonus_payments, dependent: :destroy

  scope :next_to_calculate, ->(){
    order(id: :asc).where('calculated_at is null').first }

  before_create do
    self.id ||= self.class.id_from_date(self.start_date)
  end

  def calculable?
    Date.current > self.start_date
  end

  def calculated?
    !!self.calculated_at
  end

  def calculate!
    reset_orders!
    process_orders!
    self.touch :calculated_at
  end

  def ranks
    @ranks ||= Rank.with_qualifications.entries
  end

  def orders
    @orders ||= Order.by_pay_period(self).
      includes(:user, :product).references(:user, :product).
      order(order_date: :asc).entries
  end

  def reset_orders!
    self.order_totals.destroy_all
    self.rank_achievements.destroy_all
    self.bonus_payments.destroy_all
  end

  def process_order!(order)
    totals = process_order_totals!(order)
    process_at_sale_rank_bonuses!(order)
    process_rank_achievements!(order, totals)
  end

  def process_orders!
    orders.each do |order|
      process_order!(order)
      yield(order) if block_given?
    end
    # process_at_pay_period_end_rank_bonuses!
  end

  def process_order_totals!(order)
    totals =  find_order_total(order.user_id, order.product_id)
    if totals
      totals.update_columns(
        personal:           totals.personal + order.quantity,
        group:              totals.group + order.quantity,
        personal_lifetime:  totals.personal_lifetime + order.quantity,
        group_lifetime:     totals.group_lifetime + order.quantity)
    else
      totals = new_order_total(order)
    end

    increment_upline_totals(order)
    totals
  end

  def process_rank_achievements!(order, totals = nil)
    totals ||= find_order_total(order.user_id, order.product_id)

    process_lifetime_rank_achievements(order, totals)
    process_pay_period_rank_achievements(order, totals)

    order.user.parent_ids.each do |user_id|
      parent = upline_users.find { |u| u.id == user_id }
      parent_totals = find_order_total(user_id, order.product_id)

      process_lifetime_rank_achievements(order, parent_totals, parent)
      process_pay_period_rank_achievements(order, parent_totals, parent)
    end
  end

  def process_order_bonuses(order, use_rank_at)
    bonuses = bonuses_for(order.product_id, use_rank_at)
    bonuses.each do |bonus|
      bonus.create_payments!(order, self)
    end
  end

  def process_at_sale_rank_bonuses!(order)
    process_order_bonuses(order, :sale)
  end

  def process_at_pay_period_end_rank_bonuses!
    orders.each { |order| process_bonuses(order, :pay_period_end) }
  end

  def child_totals_for(user_id, product_id)
    child_ids = direct_downline_users.select { |u| u.parent_id == user_id }.map(&:id)
    return [] if child_ids.empty?

    child_totals = self.order_totals.select do |t|
      t.product_id == product_id && child_ids.include?(t.user_id)
    end

    missing = child_ids - child_totals.map(&:user_id)
    child_totals += missing.map do |id|
      create_order_total(id, product_id)
    end
  end

  def find_order_total(user_id, product_id)
    order_totals.find do |ot|
      ot.user_id == user_id && ot.product_id == product_id
    end
  end

  def find_order_total!(user_id, product_id)
    find_order_total(user_id, product_id) || create_order_total(user_id, product_id)
  end

  def find_pay_as_rank(user)
    rank_achievements.select { |a| a.user_id == user.id }.
      map(&:rank_id).max || user.organic_rank
  end

  private

  def users_with_orders
    @users_with_orders ||= orders.map(&:user).uniq
  end

  def upline_users
    @upline_users ||= begin
      parent_ids = users_with_orders.map(&:parent_ids).flatten.uniq
      parents = users_with_orders.select { |u| parent_ids.include?(u.id) }
      missing_ids = parent_ids - parents.map(&:id)
      parents + User.select(:id, :upline, :lifetime_rank).where(id: missing_ids).entries
    end
  end

  def all_user_ids
    @all_user_ids ||= (users_with_orders.map(&:id) + upline_users.map(&:id)).uniq
  end

  def direct_downline_users
    @direct_downline_users ||= begin
      User.select(:id, :upline, :lifetime_rank).
        with_parent(*all_user_ids).entries
    end
  end

  def lifetime_rank_achievements
    @lifetime_rank_achievements ||= RankAchievement.lifetime.where(user_id: all_user_ids).entries
  end

  def highest_rank(user_id, path, *lists)
    lists.inject([ 1 ]) do |ranks, list|
      ranks << list.select { |a| a.user_id == user_id && a.path == path }.
        map(&:rank_id).max
    end.compact.max
  end

  def qualification_paths
    @qualification_paths ||= ranks.second ? ranks.second.qualification_paths : []
  end

  def process_lifetime_rank_achievements(order, totals, user = nil)
    user ||= order.user

    qualification_paths.each do |path|
      start = highest_rank(user.id, path, lifetime_rank_achievements)

      ranks[start..-1].each do |rank|
        break unless rank.lifetime_path?(path) &&
          rank.qualified_path?(path, totals)

        attrs = {
          achieved_at: order.order_date,
          user_id:     user.id,
          rank_id:     rank.id,
          path:        path }
        achievement = RankAchievement.create!(attrs)
        lifetime_rank_achievements << achievement
        if user.organic_rank < achievement.rank_id
          user.update_column(:organic_rank, achievement.rank_id)
        end
        if user.lifetime_rank < achievement.rank_id
          user.update_column(:lifetime_rank, achievement.rank_id)
        end
      end
    end
  end

  def process_pay_period_rank_achievements(order, totals, user = nil)
    user ||= order.user

    qualification_paths.each do |path|
      start = highest_rank(user.id, path,
        lifetime_rank_achievements, rank_achievements)

      ranks[start..-1].each do |rank|
        break unless rank_has_path?(rank, path) &&
          rank.qualified_path?(path, totals)

        attrs = {
          achieved_at: order.order_date,
          user_id:     user.id,
          rank_id:     rank.id,
          path:        path }
        achievement = self.rank_achievements.create!(attrs)
        if user.lifetime_rank < achievement.rank_id
          user.update_column(:lifetime_rank, achievement.rank_id)
        end
      end
    end
  end

  def lifetime_personal_totals
    @lifetime_personal_totals ||= Order.personal_totals(self.start_date).entries
  end

  def lifetime_group_totals
    @lifetime_group_totals ||= Order.group_totals(self.start_date).entries
  end

  def find_personal_lifetime(user_id, product_id)
    lifetime_personal_totals.find do |t|
      t.user_id == user_id && t.product_id == product_id
    end
  end

  def find_group_lifetime(user_id, product_id)
    lifetime_group_totals.find do |t|
      t.user_id == user_id && t.product_id == product_id
    end
  end

  def create_order_total(user_id, product_id, quantity = 0)
    pl = find_personal_lifetime(user_id, product_id)
    gl = find_group_lifetime(user_id, product_id)

    self.order_totals.create!(
      user_id:            user_id,
      product_id:         product_id,
      personal:           quantity,
      group:              quantity,
      personal_lifetime:  pl ? pl.quantity + quantity : quantity,
      group_lifetime:     gl ? gl.quantity + quantity : quantity)
  end

  def new_order_total(order)
    create_order_total(order.user_id, order.product_id, order.quantity)
  end

  def increment_upline_totals(order)
    user_ids = order.user.upline - [ order.user_id ]
    group_totals = self.order_totals.select do |ot|
      user_ids.include?(ot.user_id) && ot.product_id == order.product_id
    end

    group_totals.each do |gt|
      gt.update_columns(
        group:          gt.group + order.quantity,
        group_lifetime: gt.group_lifetime + order.quantity)
    end

    missing = user_ids - group_totals.map(&:user_id)
    missing.each do |user_id|
      pl = find_personal_lifetime(user_id, order.product_id)
      gl = find_group_lifetime(user_id, order.product_id)

      self.order_totals.create!(
        user_id:            user_id,
        product_id:         order.product_id,
        personal:           0,
        group:              order.quantity,
        personal_lifetime:  pl ? pl.quantity : 0,
        group_lifetime:     gl ? gl.quantity + order.quantity : order.quantity)
    end
  end

  def products
    @products ||= Product.all.entries
  end

  def bonuses_for(product_id, use_rank_at)
    product = products.find { |p| p.id == product_id }
    product.bonuses.select do |b|
      b.enabled? && b.use_rank_at == use_rank_at.to_s && bonus_available?(b)
    end
  end

  class << self
    def find_or_create_by_date(date)
      find_or_create_by_id(id_from(date.to_date))
    end

    def generate_missing
      first_order = Order.all_time_first
      return unless first_order

      [ MonthlyPayPeriod, WeeklyPayPeriod ].each do |period_klass|
        ids = period_klass.ids_from(first_order.order_date)
        unless ids.empty?
          existing = period_klass.where(id: ids).pluck(:id)
          ids -= existing
          ids.each { |id| period_klass.find_or_create_by_id(id) }
        end
      end
    end

    def find_or_create_by_id(id)
      klass = id.include?('W') ? WeeklyPayPeriod : MonthlyPayPeriod
      klass.find_or_create_by_id(id)
    end
  end

end
