module Auth

  class UsersController < AuthController

    before_action :fetch_user, only: [ :downline, :upline, :show, :update ]
    
    def index
      respond_to do |format|
        format.html
        format.json do
          @users = list_criteria
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
      @users = list_criteria.search(params[:search])

      render 'index'
    end

    def show
      @user = current_user.distributors.find_by(id: params[:id]) or not_found!(:user)
    end

    private

    def list_criteria
      User.where(sponsor_id: current_user.id).order(created_at: :desc)
    end

    def fetch_user
      @user = User.find_by(id: params[:id]) or not_found!(:user)
    end

  end

end