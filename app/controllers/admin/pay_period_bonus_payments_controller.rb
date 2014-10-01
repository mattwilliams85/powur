module Admin

  class PayPeriodBonusPaymentsController < BonusPaymentsController
    include ListQuery

    before_action :fetch_pay_period

    page
    sort created_at: :created_at, user: 'users.last_name asc, users.first_name asc'

    private

    def fetch_pay_period
      pay_period = PayPeriod.find(params[:pay_period_id])

      @bonus_payments = pay_period.bonus_payments
      @bonus_payments_path = pay_period_bonus_payments_path(pay_period)
    end

  end

end
