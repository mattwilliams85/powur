class BonusPaymentLead < ActiveRecord::Base
  self.primary_keys = :bonus_payment_id, :lead_id

  belongs_to :bonus_payment
  belongs_to :lead

  # scope :for_pay_period, lambda { |pay_period_id|
  #   where_arg = { bonus_payments: { pay_period_id: pay_period_id } }
  #   joins(:bonus_payment).where(where_arg)
  # }

  # scope :for_user, ->(id) { where(user_id: id.to_i) }

  # scope :for_user_pay_period, lambda { |pay_period_id, user_id|
  #   pp_where_arg = { bonus_payments: { pay_period_id: pay_period_id } }
  #   user_where_arg = { bonus_payments: { user_id: user_id } }
  #   joins(:bonus_payment)
  #     .where(pp_where_arg)
  #     .where(user_where_arg)
  #     .order('bonus_payments.bonus_id')
  # }

  class << self
    DELETE_PP_SQL = "
    DELETE FROM bonus_payment_leads
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
