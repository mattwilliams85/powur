module Auth
  class OrderTotalsController < AuthController
    before_action :fetch_user!
    before_action :fetch_pay_period, only: [ :index ]
    before_action :fetch_order_totals, only: [ :index ]

    def index
    end

    private

    def fetch_pay_period
      return unless params[:pay_period_id]
      @pay_period = PayPeriod.find(params[:pay_period_id])
    end

    def fetch_order_totals
      @order_totals = OrderTotal.all
        .includes(:product, :user)
        .references(:product, :user)

      @order_totals = @order_totals.where(user_id: @user.id) if @user
      return unless @pay_period
      @order_totals = @order_totals.where(pay_period_id: @pay_period.id)
    end

  end
end
