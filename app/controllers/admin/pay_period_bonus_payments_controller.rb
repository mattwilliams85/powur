module Admin

  class PayPeriodBonusPaymentsController < BonusPaymentsController

    before_action :fetch_pay_period

    SORTS = {
      created_at: :created_at,
      user:       'users.last_name asc, users.first_name asc' }

    sort_and_page available_sorts: SORTS

    private

    def fetch_pay_period
      pay_period = PayPeriod.find(params[:pay_period_id])

      @bonus_payments = pay_period.bonus_payments
      @bonus_payments_path = pay_period_bonus_payments_path(pay_period)
    end

  end

end
