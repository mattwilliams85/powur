module Auth

  class UserOrderTotalsController < OrderTotalsController

    before_action :fetch_user

    SORTS = {
      pay_period: { pay_period_id: :desc },
      personal:   { personal: :desc } }

    sort_and_page available_sorts: SORTS

    private

    def fetch_user
      user = User.find(params[:user_id].to_i)

      @order_totals = user.order_totals.order(:pay_period_id)
      @orders_totals_path = user_order_totals_path(user)
    end

  end

end
