module Auth
  class UserOrderTotalsController < OrderTotalsController
    before_action :fetch_user

    page
    sort pay_period: { pay_period_id: :desc }, personal: { personal: :desc }

    private

    def fetch_user
      user = User.find_by_id(params[:user_id].to_i) ||
             not_found!(:user, params[:user_id])

      @order_totals = user.order_totals.order(:pay_period_id)
      @order_totals_path = user_order_totals_path(user)
    end
  end
end
