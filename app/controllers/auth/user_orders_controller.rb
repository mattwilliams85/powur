module Auth

  class UserOrdersController < OrdersController

    page
    sort order_date: { order_date: :desc }, customer: 'customers.last_name asc'

    def index
      respond_to do |format|
        format.json do
          user = User.find_by_id(params[:user_id].to_i) or not_found!(:user, params[:user_id])
          @orders_path = user_orders_path(user)

          super(user.orders)
        end
      end
    end

  end

end
