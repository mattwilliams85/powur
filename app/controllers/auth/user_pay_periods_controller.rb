module Auth
  class UserPayPeriodsController < AuthController
    before_filter :fetch_user

    filter :time_span, options: [ :monthly, :weekly ]

    def index
      query = PayPeriod.user_has_bonuses(@user.id)
      @pay_periods = apply_list_query_options(query)
    end

    def show
      @pay_period = PayPeriod.find(params[:id])
      @bonus_totals = payments
        .select('sum(bonus_payments.amount) bonus_total, bonus_id')
        .group(:bonus_id)
      @bonus_payments = payments
        .preload(:bonus, :leads, :bonus_payment_leads,
                 leads: [ :customer, :user ])
    end

    private

    def payments
      @pay_period.bonus_payments.where(user_id: @user.id)
    end
  end
end
