module Api
  class UsersController < ApiController
    before_action :fetch_user, only: [ :show, :downline ]

    helper_method :user_path

    page
    sort user: 'users.last_name asc, users.first_name asc'

    def index
      @user = current_user
      @users = apply_list_query_options(list_criteria)

      render 'index'
    end

    def downline
      @users = apply_list_query_options(list_criteria)

      render 'index'
    end

    def show
    end

    private

    def list_criteria
      User.with_parent(@user.id)
    end

    def fetch_user
      @user = fetch_downline_user(params[:id].to_i)
    end

    def controller_path
      'auth/users'
    end

    def user_path(user)
      api_user_path(v: params[:v], id: user)
    end
  end
end
