module Auth
  class PayPeriodsController < AuthController
    before_action :fetch_user!, only: [ :index ]
    before_action :fetch_pay_period, only: [ :show, :calculate, :distribute ]

    page
    sort id_desc:         { id: :desc },
         start_date_desc: { start_date: :desc },
         start_date_asc:  { start_date: :asc },
         end_date_desc:   { end_date: :desc },
         end_date_asc:    { end_date: :asc }
    filter :time_span, options: [ :monthly, :weekly ]

    def index
      query = PayPeriod.all
      query = query.user_has_bonuses(@user.id) if @user
      @pay_periods = apply_list_query_options(query)
    end

    def show
    end

    def calculate
      t(:period_not_calculable) unless @pay_period.calculable?

      CalculatePayPeriodJob.perform_later(@pay_period.id)
      @pay_period.status = :queued

      render 'show'
    end

    def distribute
      t(:period_not_disbursable) unless @pay_period.disbursable?

      DistributePayPeriodJob.perform_later(@pay_period.id)
      @pay_period.status = :queued

      render 'show'
    end

    private

    def fetch_pay_period
      @pay_period = PayPeriod.find(params[:id])
    end
  end
end
