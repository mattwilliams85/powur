module Auth
  class UsersController < AuthController
    before_action :fetch_user, only: [ :downline, :upline, :show, :update ]

    time_period =
    order_choices =

    sort order_by: { organic_rank: :desc },
         last_name: { last_name: :desc }
         # order_by_quotes: {organic_rank: :desc}.
         # order_by_recruits: {organic_rank: :desc}
    # filter :pay_period,
    #        url:      -> { pay_periods_path },
    #        required: true,
    #        default:  -> { PayPeriod.last_id },
    #        name:     :title

    def index
      @users = apply_list_query_options(@users)
    end

    def downline
      @users = @user.downline_users

      render 'index'
    end

    def upline
      @users = @user.upline_users

      render 'index'
    end

    def search
      @users = list_criteria.search(params[:search])

      render 'index'
    end

    def team
      @users = User.where(sponsor_id: current_user.id)
      @users = apply_list_query_options(@users)
    end

    def show
    end

    private

    def team_list_criteria
      query = User.where(sponsor_id: current_user.id)

      if(params.has_key?(:order))
        query.order(organic_rank: :desc)
      end
    end

    def list_criteria
      User.where(sponsor_id: current_user.id)
    end

    def fetch_user
      @user = User.find_by(id: params[:id]) || not_found!(:user)
    end
  end
end
