class UsersController < AuthController

  def index
    @users = criteria
  end

  def search
    @users = list_criteria.search(params[:q])

    render 'index'
  end

  def show
    @user = User.find_by(id: params[:id], invitor_id: current_user.id) or not_found!(:user)
  end

  private

  def list_criteria
    User.where(invitor_id: current_user.id).order(created_at: :desc)
  end

end
