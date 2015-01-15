module Auth
  class EarningsController < AuthController
    page max_limit: 20

    def index
      @months = %w(January February March April May June July
                   August September October November December)
      render 'show.html.erb'
    end

    def show
      # Most of this is placeholder until we implement the frontend
    end

    # endpoint for ajax call that populates the earnings
    # show action
    def summary
      @user = fetch_user
      @pay_periods = fetch_pay_period_range(params).order(:type)
      @total_earnings = current_user.bonus_payments.sum(:amount)
      @earnings = fetch_earnings(@user.id, @pay_periods)
      @earnings_group = structured_earnings(@pay_periods, @earnings, @user)
      create_missing(@earnings_group) if @earnings_group.length < 5
    end

    # this call will fetch the details for a bonus payment
    # required params: user_id, pay_period_id
    def detail
      @user = fetch_user
      @pay_period = PayPeriod.find_by(id: params[:pay_period_id])
      details = fetch_earning_details(@user, @pay_period) if @pay_period
      query = apply_list_query_options(details)
      @earning_details = query
    end

    def bonus
      @user = fetch_user
      @pay_period = PayPeriod.find_by(id: params[:pay_period_id])
      @bonus_summary = BonusPayment.bonus_totals_by_type(@pay_period).for_user(@user.id)
      @total = @pay_period.bonus_payments.for_user(@user.id).sum(:amount)
    end

    def bonus_detail
      @user = fetch_user
      @pay_period = PayPeriod.find_by(id: params[:pay_period_id])
      @bonus = Bonus.find(params[:bonus_id])
      details = BonusPayment.bonus(@bonus.id).for_user(current_user.id)
      query = apply_list_query_options(details)
      @bonus_payments = query
    end

    private

    #  REFACTOR: There has to be a better way to do this.
    #  I'm attempting to show all the pay periods in the date range
    #  even if they don't have a bonus_payment (earning)
    def structured_earnings(pay_periods, earnings, user)
      @earnings_map = {}
      @earnings_map = pay_periods.map do |pp|
        { pay_period: pp,
          earning:    earnings.find_by_pay_period_id(pp.id),
          user_id:    user.id }
      end

      @earnings_map
    end

    def create_missing(earnings_group)

      # (5 - earnings_group.length).times do 
      #   @earnings_group << PayPeriod.new(:end_date)
      # end
    end

    def fetch_earning_details(user, pay_period)
      pay_period.bonus_payments.includes(bonus: [], orders: [:product, :customer]).order(:bonus_id).for_user(user.id)
    end

    def fetch_pay_period_range(params)
      range_start = DateTime.new(params[:start_year].to_i,
                                 params[:start_month].to_i, 1)
      range_end = DateTime.new(params[:end_year].to_i,
                               params[:end_month].to_i, -1)

      PayPeriod.within_date_range(range_start, range_end)
    end

    def fetch_user
      User.find(params[:user_id])
    end

    def fetch_earnings(user_id, pay_periods)
      BonusPayment.user_bonus_summary(user_id, pay_periods)
    end
  end
end
