module Admin

  class UsersController < AdminController

    before_filter :fetch_user, only: [ :downline, :upline, :show, :update ]

    def index
      @users = User.at_level(1).order(last_name: :desc, first_name: :desc)

      render 'index'
    end

    def downline
      @users = @user.downline_users(1)

      render 'index'
    end

    def upline
      @users = @user.upline_users

      render 'index'
    end

    def search
    end

    def show
    end

    def update
    end

    private

    def fetch_user
      @user = User.find(params[:id])
    end

  end

end