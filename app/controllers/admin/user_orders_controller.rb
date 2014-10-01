module Admin

  class UserOrdersController < OrdersController
    include SortAndPage

    SORTS = {
      order_date: { order_date: :desc },
      customer:   'customers.last_name asc' }

    sort_and_page available_sorts: SORTS

    def index
      user = User.find(params[:admin_user_id].to_i)
      @orders_path = admin_user_orders_path(user)

      super(user.orders)
    end

  end

end
