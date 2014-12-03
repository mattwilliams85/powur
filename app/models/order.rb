class Order < ActiveRecord::Base
  enum status: { closed: 1, cancelled: 2 }

  belongs_to :product
  belongs_to :user
  belongs_to :customer
  belongs_to :quote
  has_many :bonus_payment_orders
  has_many :bonus_payments, through: :bonus_payment_orders

  add_search :user, :customer, [ :user, :customer ]
  scope :before, ->(date) { where('order_date < ?', date.to_date) }
  scope :after, ->(date) { where('order_date >= ?', date.to_date) }
  scope :by_pay_period,
        ->(period) { before(period.end_date + 1.day).after(period.start_date) }
  scope :user_product_grouped, lambda {
    select('user_id, product_id, sum(quantity) quantity')
      .group('user_id').group('product_id').order(:user_id)
  }
  scope :status, ->(value) { where(status: value) }

  scope :personal_totals,
        ->(end_date) { before(end_date).user_product_grouped }

  GROUP_TOTALS_SQL = "
    SELECT u.id user_id, o.product_id, o.quantity
    FROM (
      SELECT unnest(u.upline) parent_id, product_id, sum(o.quantity) quantity
      FROM orders o
      INNER JOIN users u ON u.id = o.user_id
      WHERE o.order_date < :end_date
      GROUP BY parent_id, product_id) o
        INNER JOIN users u ON o.parent_id = u.id"
  scope :group_totals, lambda { |end_date|
    find_by_sql([ GROUP_TOTALS_SQL, { end_date: end_date.to_date } ])
  }
  scope :product_totals,
        -> { select('product_id, sum(quantity) quantity').group(:product_id) }

  def monthly_pay_period_id
    MonthlyPayPeriod.id_from(order_date)
  end

  def monthly_pay_period
    @monthly_pay_period ||= MonthlyPayPeriod
                            .find_or_create_by_id(monthly_pay_period_id)
  end

  def weekly_pay_period_id
    WeeklyPayPeriod.id_from(order_date)
  end

  def weekly_pay_period
    @weekly_pay_period ||= WeeklyPayPeriod
                           .find_or_create_by_id(weekly_pay_period_id)
  end

  def bonus_payments?
    bonus_payments.size > 0
  end

  class << self
    def all_time_first
      Order.order(order_date: :asc).first
    end
  end
end
