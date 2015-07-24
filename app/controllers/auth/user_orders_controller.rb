module Auth
  class UserOrdersController < OrdersController
    before_action :fetch_user

    page
    sort order_date: { order_date: :desc },
         customer:   'customers.last_name asc, customers.first_name asc'
    filter :status, options: Order.enum_options(:statuses)

    def index
      @orders_path = user_orders_path(@user)

      super(@user.orders)
    end
  end
end
