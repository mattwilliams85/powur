class InvitesController < AuthController

  def index
  end

  def create
    keys = [ :email, :first_name, :last_name, :phone ]
    require_input *keys

    if current_user.invites.count >= PromoterConfig.max_invites
      error! t('errors.max_invites')
    end

    invite = current_user.send_invite(params.permit(*keys))

    render json: {}
  end
end