module Admin

  class PayPeriodsController < AdminController

    before_filter :fetch_pay_period, only: [ :calculate, :show ]

    def index
      respond_to do |format|
        format.html { render 'index' }
        format.json do
          PayPeriod.generate_missing
          @pay_periods = PayPeriod.all.order(start_date: :desc)

          render 'index'
        end
      end
    end

    def show
    end

    def calculate
      @pay_period.calculate!

      render 'show'
    end

    private

    def fetch_pay_period
      @pay_period = PayPeriod.find(params[:id])
    end

  end
end
