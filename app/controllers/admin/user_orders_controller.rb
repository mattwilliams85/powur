module Admin
  class UserOrdersController < OrdersController
    page
    sort order_date: { order_date: :desc },
         customer:   'customers.last_name asc'
    # TODO: add filters for pay period

    def index
      user = User.find(params[:admin_user_id].to_i)
      @orders_path = admin_user_orders_path(user)

      super(user.orders)
    end
  end
end
