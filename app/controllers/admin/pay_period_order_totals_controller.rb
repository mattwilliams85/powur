module Admin

  class PayPeriodOrderTotalsController < OrderTotalsController

    before_action :fetch_pay_period

    private

    def fetch_pay_period
      pay_period = PayPeriod.find(params[:pay_period_id])

      @order_totals = pay_period.order_totals.order(:user_id)
      @orders_totals_path = pay_period_order_totals_path(pay_period)
    end

  end

end
