module Admin

  class PayPeriodOrderTotalsController < OrderTotalsController

    before_action :fetch_pay_period

    SORTS = {
      user:     'users.last_name asc',
      personal: { personal: :desc } }

    sort_and_page available_sorts: SORTS

    private

    def fetch_pay_period
      pay_period = PayPeriod.find(params[:pay_period_id])

      @order_totals = pay_period.order_totals
      @orders_totals_path = pay_period_order_totals_path(pay_period)
    end

  end

end
