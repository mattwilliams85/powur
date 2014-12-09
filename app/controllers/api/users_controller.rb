module Api
  class UsersController < ApiController
    before_action :fetch_user, only: [ :downline ]

    page
    sort user: 'users.last_name asc, users.first_name asc'

    def index
      @user ||= current_user
      @users = apply_list_query_options(list_criteria)

      render 'index'
    end

    def downline
      @self_path = downline_api_user_path(v: params[:v], id: @user)
      index
    end

    private

    def list_criteria
      User.with_parent(@user.id)
    end

    def fetch_user
      @user = fetch_downline_user(params[:id].to_i)
    end

  end
end
