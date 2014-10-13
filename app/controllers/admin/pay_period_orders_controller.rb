module Admin
  class PayPeriodOrdersController < OrdersController
    page
    sort order_date: { order_date: :desc },
         customer:   'customers.last_name asc'

    def index
      pay_period = PayPeriod.find(params[:pay_period_id])
      @orders_path = pay_period_orders_path(pay_period)

      super(pay_period.orders)
    end
  end
end
