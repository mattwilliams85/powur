module Auth
  class OrderTotalsController < AuthController
    before_action :fetch_user

    def index
      @order_totals = OrderTotal.all
        .includes(:product, :user).references(:product, :user)
      @user ||= current_user unless admin?
      @order_totals = @order_totals.where(user_id: @user.id) if @user
      if params[:pay_period_id]
        pay_period = PayPeriod.find(params[:pay_period_id])
        @order_totals = @order_totals.where(pay_period_id: params[:pay_period_id])
      end
    end

  end
end
