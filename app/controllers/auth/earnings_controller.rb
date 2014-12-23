module Auth
  class EarningsController < AuthController
    def index
      @months = [ "January", "February", "March", "April", "May", "June",
          "July", "August", "September", "October", "November", "December" ]
      render 'show.html.erb'
    end

    def show

      # Most of this is placeholder until we implement the frontend
      # @user = current_user
      # @downline = @user.downline_users
      # @total_earnings = current_user.bonus_payments.sum(:amount)
      # @downline.each do |user|
      #   @total_earnings += user.bonus_payments.sum(:amount)
      # end
    end

    # endpoint for ajax call that populates the earnings
    # show action
    def summary

      @user = current_user
      @downline = @user.downline_users
      @total_earnings = current_user.bonus_payments.sum(:amount)
      @downline.each do |user|
        @total_earnings += user.bonus_payments.sum(:amount)
      end
      @user = fetch_user
      @pay_periods = fetch_pay_period_range(params)
      @earnings = fetch_earnings(params, @pay_periods)
    end

    # this call will fetch the details for a bonus payment
    # required params: user_id, pay_period_id
    def detail
      @user = fetch_user
      @pay_period = PayPeriod.find(params[:pay_period_id])
      @earning_details = fetch_earning_details(@user, @pay_period)
    end

    private

    def fetch_earning_details(user, pay_period)
      pay_period.bonus_payments.for_user(user.id)
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

    def fetch_earnings(params, pay_periods)
      BonusPayment.user_bonus_summary(params[:user_id], pay_periods)
    end
  end
end
