module Auth
  class PayPeriodsController < AuthController
    before_action :fetch_pay_periods, only: [ :index ]

    filter :time_span, options: [ :monthly, :weekly ]

    def index
      @pay_periods = apply_list_query_options(@pay_periods)
    end

    def show
      @pay_period = PayPeriod.find(params[:id])
    end

    private

    def fetch_pay_periods
      PayPeriod.generate_missing
      @pay_periods = PayPeriod.order(id: :desc)
    end
  end
end
