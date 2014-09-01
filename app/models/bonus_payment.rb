class BonusPayment < ActiveRecord::Base

  enum status: { pending: 1, paid: 2, cancelled: 3 }

  belongs_to :pay_period
  belongs_to :bonus
  belongs_to :user
  has_many :orders, through: :bonus_payment_orders
end
