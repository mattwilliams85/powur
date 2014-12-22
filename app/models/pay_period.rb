class PayPeriod < ActiveRecord::Base
  include Calculator::RankAchievements
  include Calculator::OrderTotals
  include Calculator::Bonuses
  include EwalletDSL

  has_many :order_totals, dependent: :destroy
  has_many :rank_achievements, dependent: :destroy
  has_many :bonus_payments, dependent: :destroy
  has_many :bonus_payment_orders, through: :bonus_payments, dependent: :destroy

  scope :calculated, -> { where('calculated_at is not null') }
  scope :next_to_calculate,
        -> { order(id: :asc).where('calculated_at is null').first }

  scope :dispursed, -> { where('dispursed_at is not null') }

  scope :within_date_range, lambda { |range_start, range_end|
                              where(start_date: range_start..range_end)
                            }
  before_create do
    self.id ||= self.class.id_from(start_date)
  end

  def title
    "#{type_display} (#{start_date} - #{end_date})"
  end

  def date_range_display(format = nil)
    if format
      "#{start_date.strftime(format)} - #{end_date.strftime(format)}"
    else
      "#{start_date} - #{end_date}"
    end
  end

  def finished?
    Date.current > end_date
  end

  def disbursed?
    !disbursed_at.nil?
  end

  def disbursable?
    finished? && calculated? && !disbursed?
  end

  def disburse!
    payments_per_user = BonusPayment.user_bonus_totals(self)

    query = prepare_load_request(self, payments_per_user)

    ewallet_request(:ewallet_load, query)
  end

  def calculated?
    !calculated_at.nil?
  end

  def calculating?
    !calculate_started.nil? && !calculated?
  end

  def calculable?
    !disbursed? && DateTime.current > start_date && !calculating?
  end

  def queue_calculate
    touch(:calculate_queued)
    update_attribute(:calculate_started, nil)
    delay.calculate!
  end

  def calculate!
    result = self.class
             .where(id: id)
             .where('calculate_queued is not null')
             .update_all(calculate_started: DateTime.current,
                         calculate_queued:  nil,
                         calculated_at:     nil)
    return unless result == 1
    reset_orders!
    process_orders!
    touch :calculated_at
  end

  def ranks
    @ranks ||= Rank.with_qualifications.entries
  end

  def orders
    @orders ||= Order.by_pay_period(self)
                .includes(:user, :product).references(:user, :product)
                .order(order_date: :asc)
  end

  def reset_orders!
    BonusPaymentOrder.delete_all_for_pay_period(id)
    bonus_payments.delete_all
    rank_achievements.delete_all
    order_totals.delete_all
  end

  def process_orders!
    orders.each do |order|
      process_order!(order)
      yield(order) if block_given?
    end
    process_at_pay_period_end_rank_bonuses!
  end

  def process_order!(order)
    totals = process_order_totals!(order)
    process_at_sale_rank_bonuses!(order)
    process_rank_achievements!(order, totals)
  end

  def child_totals_for(user_id, product_id)
    child_ids = direct_downline_users
                .select { |u| u.parent_id == user_id }.map(&:id)
    return [] if child_ids.empty?

    child_totals = order_totals.select do |t|
      t.product_id == product_id && child_ids.include?(t.user_id)
    end

    missing = child_ids - child_totals.map(&:user_id)
    child_totals + missing.map do |id|
      create_order_total(id, product_id)
    end
  end

  def find_order_total(user_id, product_id)
    order_totals.find do |ot|
      ot.user_id == user_id && ot.product_id == product_id
    end
  end

  def find_order_total!(user_id, product_id)
    find_order_total(user_id, product_id) ||
      create_order_total(user_id, product_id)
  end

  def find_pay_as_rank(user)
    user.pay_period_rank ||= rank_achievements
                             .select { |a| a.user_id == user.id }
                             .map(&:rank_id).max
    user.pay_as_rank
  end

  def find_upline_user(user_id)
    upline_users.find { |u| u.id == user_id }
  end

  def user_active?(user)
    user_active_list[user.id] ||= user_qualified_active?(user)
  end

  def compressed_upline(user)
    upline = user.parent_ids.map do |id|
      upline_users.find { |u| u.id == id }
    end
    upline.select { |u| user_active?(u) }.reverse
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
      parents + User.for_bonuses.where(id: missing_ids).entries
    end
  end

  def all_user_ids
    @all_user_ids ||=
      (users_with_orders.map(&:id) + upline_users.map(&:id)).uniq
  end

  def direct_downline_users
    @direct_downline_users ||= begin
      User.for_bonuses.with_parent(*all_user_ids).entries
    end
  end

  def lifetime_personal_totals
    @lifetime_personal_totals ||= Order.personal_totals(start_date).entries
  end

  def lifetime_group_totals
    @lifetime_group_totals ||= Order.group_totals(start_date).entries
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

    order_totals.create!(
      user_id:           user_id,
      product_id:        product_id,
      personal:          quantity,
      group:             quantity,
      personal_lifetime: pl ? pl.quantity + quantity : quantity,
      group_lifetime:    gl ? gl.quantity + quantity : quantity)
  end

  def new_order_total(order)
    create_order_total(order.user_id, order.product_id, order.quantity)
  end

  def products
    @products ||= Product.with_bonuses.entries
  end

  def bonuses_for(product_id, use_rank_at)
    product = products.find { |p| p.id == product_id }
    product.bonuses.select do |b|
      b.enabled? && b.use_rank_at == use_rank_at.to_s && bonus_available?(b)
    end
  end

  def user_active_list
    @user_active_list ||= {}
  end

  def active_qualifiers
    @active_qualifiers ||= Qualification.active
  end

  def user_qualified_active?(user)
    qualifiers = (active_qualifiers[nil] || []) +
                 (active_qualifiers[user.rank_path_id] || [])
    return true if qualifiers.empty?

    qualifiers.all? do |qualifier|
      totals = find_order_total!(user.id, qualifier.product_id)
      qualifier.met?(totals)
    end
  end

  class << self
    def current
      find_or_create_by_date(Date.current)
    end

    def find_or_create_by_date(date)
      find_or_create_by_id(id_from(date.to_date))
    end

    def generate_missing
      first_order = Order.all_time_first
      return unless first_order

      [ MonthlyPayPeriod, WeeklyPayPeriod ].each do |period_klass|
        ids = period_klass.ids_from(first_order.order_date)
        next if ids.empty?
        existing = period_klass.where(id: ids).pluck(:id)
        ids -= existing
        ids.each { |id| period_klass.find_or_create_by_id(id) }
      end
    end

    def find_or_create_by_id(id)
      klass = id.include?('W') ? WeeklyPayPeriod : MonthlyPayPeriod
      klass.find_or_create_by_id(id)
    end

    def last_id
      most_recent = calculated.order(start_date: :desc).first
      most_recent && most_recent.id
    end
  end
end
