class BonusPayment < ActiveRecord::Base
  enum status: { pending: 1, paid: 2, cancelled: 3 }

  belongs_to :pay_period
  belongs_to :bonus
  belongs_to :user

  has_many :bonus_payment_orders, dependent: :destroy
  has_many :orders, through: :bonus_payment_orders

  scope :pay_period, ->(id) { where(pay_period: id) }
  scope :bonus, ->(id) { where(bonus_id: id) }
end
