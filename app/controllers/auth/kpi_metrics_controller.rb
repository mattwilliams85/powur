module Auth
  class KpiMetricsController < AuthController
    helper_method :users_for_period
    helper_method :orders_for_user

    def index
    
    end

    def show
      @contributor = current_user
      @user_orders = []
      generate_periods
    end

    def generate_periods
      @periods = []
      (Time.now.strftime("%U").to_i).times do |i|
        @periods << "#{Time.now.strftime("%Y")}W#{i + 1}"
      end
      @periods
    end

    def users_for_period(total_downline, period)
      @period = period
      users_for_period = []
      total_downline.each do |user|
        user.orders.each do |order|
          if order.order_date.strftime("%YW%U") == period
            @user_orders << order
            users_for_period << user
          end
        end
      end
      users_for_period
    end

    def orders_for_user(orders, user_id)
      orders_for_user = []
      orders.each do |order|
        if order.user_id == user_id
          orders_for_user << order
        end
      end
      orders_for_user
    end

  end
end
