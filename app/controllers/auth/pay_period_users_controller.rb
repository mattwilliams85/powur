module Auth
  class PayPeriodUsersController < AuthController
    before_filter :fetch_pay_period
    before_filter :fetch_lead_totals, only: [ :index ]
    before_filter :fetch_highest_ranks, only: [ :index ]

    page
    sort personal_monthly: { personal: :desc },
         team_monthly:     { team: :desc },
         user:             'users.last_name asc, users.first_name asc'

    def index
      @lead_totals = apply_list_query_options(@lead_totals)
    end

    def show
    end

    private

    def fetch_pay_period
      @pay_period = PayPeriod.find(params[:pay_period_id])
    end

    def fetch_lead_totals
      @lead_totals = LeadTotals
        .where(pay_period_id: @pay_period.id)
        .joins(:user).includes(:user)
    end

    def fetch_highest_ranks
      @highest_ranks = UserUserGroup.highest_ranks(pay_period_id: @pay_period.id)
    end
  end
end
