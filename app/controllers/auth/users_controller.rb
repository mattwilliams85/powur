module Auth

  class UsersController < AuthController

    def index
      @users = list_criteria
    end

    def search
      @users = list_criteria.search(params[:q])

      render 'index'
    end

    def show
      @user = current_user.distributors.find_by(id: params[:id]) or not_found!(:user)
    end

    private

    def list_criteria
      User.where(sponsor_id: current_user.id).order(created_at: :desc)
    end

  end

end