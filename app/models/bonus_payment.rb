class BonusPayment < ActiveRecord::Base
  enum status: { pending: 1, paid: 2, cancelled: 3 }

  belongs_to :pay_period
  belongs_to :bonus
  belongs_to :user

  has_many :bonus_payment_orders, dependent: :destroy
  has_many :orders, through: :bonus_payment_orders

  scope :pay_period, ->(id) { where(pay_period: id) }
  scope :bonus, ->(id) { where(bonus_id: id) }
  scope :before, ->(date) { where('created_at < ?', date.to_date) }
  scope :after, ->(date) { where('created_at >= ?', date.to_date) }
  scope :by_pay_period,
        ->(period) { before(period.end_date + 1.day).after(period.start_date) }
  scope :user_payout_grouped, lambda {
    select('user_id, sum(amount) amount').group('user_id')
                                         .by_pay_period
                                         .order(:user_id)
  }

  scope :user_bonus_totals,
        ->(period) { select('user_id, sum(amount) amount')
             .by_pay_period(period)
             .group(:user_id)
             .order(:user_id) }
end

# pp = PayPeriod.find("2014-09");
# BonusPayment.user_payout_grouped(self.start_date).entries
