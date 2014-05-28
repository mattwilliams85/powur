class InvitesController < AuthController

  def index
  end

  def create
    input = params.permit(*:email, :first_name, :last_name, :phone)

    invite = current_user.send_invite(input)

    render json: {}
  rescue ActiveRecord::RecordInvalid => e
    raise e unless e.record.errors.first.first == :invitor
    error!(e.message)
  end
end