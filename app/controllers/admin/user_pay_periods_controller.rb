module Admin
  class UserPayPeriodsController < AdminController
    before_filter :fetch_user

    page
    sort start_date: :start_date, secondary: false

    def index
      PayPeriod.generate_missing
      @pay_periods = apply_list_query_options(
        PayPeriod.where('end_date >= ?', @user.created_at.to_date))
    end

    def show
      @pay_period = PayPeriod.find(params[:id])
      @order_totals = @user.order_totals.where(pay_period_id: @pay_period.id)
      @bonus_payments = @user.bonus_payments
                        .where(pay_period_id: @pay_period.id).bonus_sums
    end
  end
end
