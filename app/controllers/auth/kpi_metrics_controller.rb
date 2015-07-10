module Auth
  class KpiMetricsController < AuthController
    helper_method :users_for_period
    helper_method :orders_for_user

    page max_limit: 8

    def show
      @user = current_user
      downline_ids = User.with_ancestor(@user.id).pluck(:id) 
      @proposal_count = Quote.where(user_id: downline_ids).submitted.count + @user.quotes.submitted.count
      @team_count = User.with_ancestor(@user.id).count
    end

    def proposals_show
      @user = User.find(params[:id])
      scale = params[:scale].to_i + 1
      @orders = @user.fetch_total_orders(Date.today - scale, Date.today)
      @proposals = @user.fetch_total_proposals(Date.today - scale, Date.today)

      render "auth/kpi_metrics/proposals/show"
    end

    def proposals_index
      @user = User.find(params[:id])
      @users = apply_list_query_options(User.quote_performance(@user.id))

      @max_page = (pager.meta[:item_count]/4.to_f).ceil

      render "auth/kpi_metrics/proposals/index"
    end

    def genealogy_show
      @user = User.find(params[:id])
      scale = params[:scale].to_i + 1
      @downline = @user
                    .fetch_full_downline
                    .select("users.id, users.created_at, users.first_name, users.last_name")
                    .within_date_range(Date.today - scale, Date.today)

      render "auth/kpi_metrics/genealogy/show"
    end

    def genealogy_index
      @user = User.find(params[:id])
      @users = apply_list_query_options(User.growth_performance(@user.id))
      @max_page = (pager.meta[:item_count]/4.to_f).ceil

      render "auth/kpi_metrics/genealogy/index"
    end

    def generate_periods
      @periods = []
      (Time.now.strftime('%U').to_i).times do |i|
        @periods << "#{Time.now.strftime('%Y')}W#{i + 1}"
      end
      @periods
    end

    def users_for_period(total_downline, period)
      @period = period
      users_for_period = []
      total_downline.each do |user|
        user.orders.each do |order|
          if order.order_date.strftime('%YW%U') == period
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
