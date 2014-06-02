class UsersController < AuthController

  def index

    @users = User.where(invitor_id: current_user.id)

  end

end
