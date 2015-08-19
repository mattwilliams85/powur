module Auth
  class PayPeriodUsersController < AuthController
    before_filter :fetch_pay_period
    before_filter :fetch_lead_totals, only: [ :index ]

    page
    sort personal_monthly: { personal: :desc },
         team_monthly:     { team: :desc },
         user:             'users.last_name asc, users.first_name asc'

    def index
      @lead_totals = apply_list_query_options(@lead_totals)
      @bonus_totals = payments.group(:user_id).sum(:amount)
    end

    def show
      @lead_totals = fetch_lead_totals.where(user_id: params[:id].to_i).first
      @user = @lead_totals.user
      @bonus_totals = payments
        .where(user_id: @user.id)
        .group(:user_id).sum(:amount)
      @bonus_payments = payments
        .where(user_id: @user.id)
        .preload(:bonus, :leads, :bonus_payment_leads,
                 leads: [ :customer, :user ])
    end

    private

    def payments
      @pay_period.bonus_payments
    end

    def fetch_pay_period
      @pay_period = PayPeriod.find(params[:pay_period_id])
    end

    def fetch_lead_totals
      @lead_totals = LeadTotals
        .where(pay_period_id: @pay_period.id)
        .joins(:user).includes(:user)
        .preload(user: [ :user_ranks, :overrides ])
    end
  end
end
