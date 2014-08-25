module Admin

  class PayPeriodsController < AdminController

    before_filter :fetch_pay_period, only: [ :show, :calculate, :recalculate ]

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

    def recalculate
      @pay_period.destroy
      @pay_period = PayPeriod.find_or_create_by_id(@pay_period.id)

      calculate
    end

    private

    def fetch_pay_period
      @pay_period = PayPeriod.find_or_create_by_id(params[:id])
    end

  end
end
