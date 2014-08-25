module Admin

  class UserOrdersController < OrdersController

    sort_and_page available_sorts: SORTS

    def index
      user = User.find(params[:admin_user_id].to_i)
      @orders_path = admin_user_orders_path(user)

      super(user.orders)
    end

  end

end