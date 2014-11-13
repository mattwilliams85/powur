class BonusPayment < ActiveRecord::Base
  enum status: { pending: 1, paid: 2, cancelled: 3 }

  belongs_to :pay_period
  belongs_to :bonus
  belongs_to :user

  has_many :bonus_payment_orders, dependent: :destroy
  has_many :orders, through: :bonus_payment_orders

  scope :pay_period, ->(id) { where(pay_period: id) }

  scope :bonus, ->(id) { where(bonus_id: id.to_i) }
  scope :before, ->(date) { where('created_at < ?', date.to_date) }
  scope :after, ->(date) { where('created_at >= ?', date.to_date) }

  scope :user_bonus_totals, ->(period) { select('user_id, sum(amount) AMOUNT')
                             .pay_period(period)
                             .group(:user_id)
                             .order(:user_id)
                            }


  scope :bonus_sums, lambda {
    select('bonus_id, sum(amount) amount, count(id) quantity')
      .includes(:bonus).group(:bonus_id)
  }
end
