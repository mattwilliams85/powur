module Admin
  class UserOrderTotalsController < OrderTotalsController
    before_action :fetch_user
    before_action :fetch_order_totals

    page
    sort pay_period: { pay_period_id: :desc },
         personal:   { personal: :desc }

    private

    def fetch_order_totals
      @order_totals = user.order_totals
      @orders_totals_path = admin_user_order_totals_path(user)
    end
  end
end
