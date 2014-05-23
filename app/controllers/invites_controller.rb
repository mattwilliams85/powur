class InvitesController < AuthController

  def index
  end

  def create
    keys = [ :email, :first_name, :last_name, :phone ]
    require_input *keys

    invite = current_user.send_invite(params.permit(*keys))

    render json: {}
  end
end