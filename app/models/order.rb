class Order < ActiveRecord::Base

  enum status: { pending: 1, shipped: 2, cancelled: 3, refunded: 4 }

  belongs_to :bonus_plan
  belongs_to :product
  belongs_to :user
  belongs_to :customer
  belongs_to :quote

  add_search :user, :customer, [ :user, :customer ]
  scope :before, ->(date){ where('order_date < ?', date.to_date + 1.day) }
  scope :after, ->(date){ where('order_date >= ?', date.to_date) }
  scope :by_pay_period, ->(period){
    before(period.start_date).after(period.end_date) }
  scope :user_product_grouped, ->(){
    select('user_id, product_id, sum(quantity) quantity').
      group('user_id').group('product_id').order(:user_id) }
  scope :personal_totals, ->(start_date, end_date){
    after(start_date).before(end_date).user_product_grouped }
  GROUP_TOTALS_SQL = "
    SELECT u.id user_id, o.product_id, o.quantity
    FROM (
      SELECT unnest(u.upline) parent_id, product_id, sum(o.quantity) quantity
      FROM orders o
      INNER JOIN users u ON u.id = o.user_id
      WHERE o.order_date >= :start_date AND o.order_date < :end_date
      GROUP BY parent_id, product_id) o INNER JOIN users u ON o.parent_id = u.id"
  scope :group_totals, ->(start_date, end_date){
    find_by_sql([ GROUP_TOTALS_SQL, { start_date: start_date.to_date, end_date: end_date.to_date + 1.day } ]) }
    
  def monthly_pay_period_id
    MonthlyPayPeriod.id_from(order_date)
  end

  def monthly_pay_period
    @monthly_pay_period ||= MonthlyPayPeriod.find_or_create_by_id(monthly_pay_period_id)
  end

  def weekly_pay_period_id
    WeeklyPayPeriod.id_from(order_date)
  end

  def weekly_pay_period
    @weekly_pay_period ||= WeeklyPayPeriod.find_or_create_by_id(weekly_pay_period_id)
  end

  def increment_order_totals!
    
  end

  class << self
    def all_time_first
      Order.order(order_date: :asc).first
    end
  end

end
