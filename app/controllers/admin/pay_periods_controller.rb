module Admin
  class PayPeriodsController < AdminController
    before_action :fetch_pay_periods, except: [ :index ]
    before_action :fetch_pay_period, only: [ :show, :calculate, :recalculate ]

    helper_method :can_calculate?
    helper_method :can_distribute?

    filter :calculated, scope_opts: { type: :boolean }
    filter :distributed, scope_opts: { type: :boolean }

    def index
      respond_to do |format|
        format.html { render 'index' }
        format.json do
          @pay_periods = apply_list_query_options(fetch_pay_periods)
          render 'index'
        end
      end
    end

    def show
      product_totals = @pay_period.order_totals.product_totals
      @totals = product_totals_hash(product_totals)
      if @pay_period.calculated?
        bonus_amount = @pay_period.bonus_payments.sum(:amount)
        @totals << { id: :bonus, value: bonus_amount, type: :currency }
      end

      if @pay_period.distributed?
        bonus_amount = @pay_period.bonus_payments.sum(:amount)
        @totals << { id: :bonus, value: bonus_amount, type: :currency }
      end

      render 'show'
    end

    def calculate
      unless can_calculate?(@pay_period)
        error! t('errors.period_not_calculable')
      end
      @pay_period.calculate!

      render 'index'
    end

    def recalculate
      @pay_period.destroy
      @pay_period = PayPeriod.find_or_create_by_id(@pay_period.id)

      calculate
    end

    def distribute
      unless can_distribute?(@pay_period)
        error! t('errors.period_not_distributable')
      end
      @pay_period.distribute!
    end

    private

    def fetch_pay_periods
      PayPeriod.generate_missing
      @pay_periods = PayPeriod.order(start_date: :desc)
    end

    def fetch_pay_period
      @pay_period = @pay_periods.find { |pp| pp.id == params[:id] }
    end

    def can_calculate?(period)
      return false unless period.calculable?
      @calculable_pay_periods ||= begin
        periods = %w(WeeklyPayPeriod MonthlyPayPeriod).map do |type|
          list = @pay_periods.select do |pp|
            pp.type == type && pp.calculated_at.nil?
          end
          list.last
        end
        periods.compact.map(&:id)
      end
      @calculable_pay_periods.include?(period.id)
    end

    def can_distribute?(period)
      return false unless period.distributable?
      @distributable_pay_periods ||= begin
        periods = %w(WeeklyPayPeriod MonthlyPayPeriod).map do |type|
          list = @pay_periods.select do |pp|
            pp.type == type && pp.distributed_at.nil?
          end
          list.last
        end
        periods.compact.map(&:id)
      end
      @distributable_pay_periods.include?(period.id)
    end
  end
end
