module Auth
  class PayPeriodUsersController < AuthController
    before_filter :fetch_pay_period
    before_filter :fetch_users, only: :index

    page
    sort bonus_total: 'bp.bonus_total desc',
         user:        'users.last_name asc, users.first_name asc'

    def index
      @users = apply_list_query_options(@users)
    end

    def show
      @user = User.find(params[:id].to_i)
      if @pay_period.monthly?
        @lead_totals = @pay_period.lead_totals.where(user_id: @user.id)
      end
      @bonus_total = payments.where(user_id: @user.id).sum(:amount)
      @bonus_payments = payments
        .where(user_id: @user.id)
        .preload(:bonus, :leads, :bonus_payment_leads,
                 leads: [ :customer, :user ])
    end

    private

    def payments
      @pay_period.bonus_payments.for_pay_period
    end

    def fetch_pay_period
      @pay_period = PayPeriod.find(params[:pay_period_id])
    end

    def fetch_users
      join = payments
        .select('sum(bonus_payments.amount) bonus_total, bonus_payments.user_id')
        .group(:user_id)
      @users = User.select('users.*, bp.*')
        .joins("INNER JOIN (#{join.to_sql}) bp ON bp.user_id = users.id")
        .preload(:user_ranks, :overrides)
    end
  end
end
