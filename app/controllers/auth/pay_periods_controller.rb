module Auth
  class PayPeriodsController < AuthController
    before_action :verify_admin, only: [ :show, :calculate ]

    page
    sort id_desc:         { id: :desc },
         start_date_desc: { start_date: :desc },
         start_date_asc:  { start_date: :asc },
         end_date_desc:   { end_date: :desc },
         end_date_asc:    { end_date: :asc }

    before_action :fetch_user!, :generate_missing, only: [ :index ]
    before_action :fetch_pay_period, only: [ :show, :calculate ]

    filter :time_span, options: [ :monthly, :weekly ]

    def index
      query = PayPeriod.all
      if @user
        from = [
          @user.created_at.beginning_of_week,
          @user.created_at.beginning_of_month ].min
        query = query.where('start_date >= ?', from)
      end
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

    def generate_missing
      PayPeriod.generate_missing
    end
  end
end
