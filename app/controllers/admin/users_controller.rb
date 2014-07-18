module Admin

  class UsersController < AdminController

    before_action :fetch_user, only: [ :downline, :upline, :show, :update ]

    def index
      respond_to do |format|
        format.html
        format.json do
          @users = User.at_level(1).order(last_name: :desc, first_name: :desc)
        end
      end
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
      @users = User.search(params[:q])

      render 'index'
    end

    def show
    end

    def update
      input = allow_input(:first_name, :last_name, 
        :email, :phone, :address, :city, :state, :zip)

      @user.update_attributes!(input)

      render 'show'
    end

    private

    def fetch_user
      @user = User.find(params[:id])
    end

  end

end