module Admin
  class PayPeriodsController < AdminController
    page
    sort start_date_desc: { start_date: :desc },
         start_date_asc:  { start_date: :asc },
         end_date_desc:   { end_date: :desc },
         end_date_asc:    { end_date: :asc }

    filter :time_span, options: [ :monthly, :weekly ]
    filter :calculated, scope_opts: { type: :boolean }
    filter :disbursed, scope_opts: { type: :boolean }

    before_action :generate_missing
    before_action :fetch_pay_period, only: [ :show, :calculate,
                                             :recalculate, :disburse ]

    helper_method :can_calculate?, :can_disburse?

    def index
      @pay_periods = apply_list_query_options(PayPeriod)
      render 'index'
    end

    def show
      product_totals = @pay_period.order_totals.product_totals
      @totals = product_totals_hash(product_totals)
      if @pay_period.calculated?
        bonus_amount = @pay_period.bonus_payments.sum(:amount)
        @totals << { id: :bonus, value: bonus_amount, type: :currency }
      end

      if @pay_period.disbursed?
        bonus_amount = @pay_period.bonus_payments.sum(:amount)
        @totals << { id: :bonus, value: bonus_amount, type: :currency }
      end

      render 'show'
    end

    def calculate
      t(:period_not_calculable) unless can_calculate?(@pay_period)

      @pay_period.queue_calculate

      render 'index'
    end

    def recalculate
      @pay_period.destroy
      @pay_period = PayPeriod.find_or_create_by_id(@pay_period.id)

      calculate
    end

    def disburse
      error!(:period_not_disbursable) unless @pay_period.disbursable?
      @pay_period.disburse!
      render 'index'
    end

    private

    def generate_missing
      PayPeriod.generate_missing
    end

    def fetch_pay_period
      @pay_period = PayPeriod.find { |pp| pp.id == params[:id] }
    end

    def can_calculate?(period)
      return false unless period.calculable?
      @calculable_pay_periods ||= begin
        periods = %w(WeeklyPayPeriod MonthlyPayPeriod).map do |type|
          list = PayPeriod.select do |pp|
            pp.type == type && pp.calculated_at.nil?
          end
          list.last
        end
        periods.compact.map(&:id)
      end
      @calculable_pay_periods.include?(period.id)
    end

    def can_disburse?(period)
      return false unless period.disbursable?

      @disbursable_pay_periods ||= begin
        periods = %w(WeeklyPayPeriod MonthlyPayPeriod).map do |type|
          list = PayPeriod.select do |pp|
            pp.type == type && pp.disbursed_at.nil?
          end
          list.last
        end
        periods.compact.map(&:id)
      end
      @disbursable_pay_periods.include?(period.id)
    end
  end
end
