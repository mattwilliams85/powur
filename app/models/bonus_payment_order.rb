class BonusPaymentOrder < ActiveRecord::Base

  self.primary_keys = :bonus_payment_id, :order_id

  belongs_to :bonus_payment
  belongs_to :order

  scope :for_pay_period, ->(pay_period_id) {
    where_arg = { bonus_payments: { pay_period_id: pay_period_id } }
    joins(:bonus_payment).where(where_arg) }

  class << self
    DELETE_PP_SQL = "
    DELETE FROM bonus_payment_orders 
    WHERE bonus_payment_id IN 
      (SELECT id
       FROM bonus_payments
       WHERE pay_period_id = ?)"

    def delete_all_for_pay_period(pay_period_id)
      sql = sanitize_sql([ DELETE_PP_SQL, pay_period_id ])
      connection.execute(sql)
    end
  end
end
