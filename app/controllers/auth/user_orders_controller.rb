module Auth
  class UserOrdersController < OrdersController
    page
    sort order_date: { order_date: :desc },
         customer:   'customers.last_name asc, customers.first_name asc'
    filter :status, options: Order.enum_options(:statuses)

    def index
      respond_to do |format|
        format.json do
          user = fetch_downline_user(params[:user_id].to_i)
          @orders_path = user_orders_path(user)

          super(user.orders)
        end
      end
    end
  end
end
