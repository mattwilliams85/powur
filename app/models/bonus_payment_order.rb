class BonusPaymentOrder < ActiveRecord::Base

  self.primary_keys = :bonus_payment_id, :order_id

  belongs_to :bonus_payment
  belongs_to :order
end
