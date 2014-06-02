class UsersController < AuthController

  def index

    @users = User.where(invitor_id: current_user.id).order(created_at: :desc)

  end

  def show
    @user = current_user
  end

end
