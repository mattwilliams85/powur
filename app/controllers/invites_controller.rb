class InvitesController < AuthController

  before_filter :fetch_invite, only: [ :renew, :resend, :destroy ]

  def index
  end

  def create
    input = params.permit(:email, :first_name, :last_name, :phone)

    @invite = current_user.create_invite(input)

    render 'invites/show'
  rescue ActiveRecord::RecordInvalid => e
    raise e unless e.record.errors.first.first == :invitor
    error!(e.message)
  end

  def renew
    @invite.renew

    render 'invites/show'
  end

  def resend
    current_user.send_invite(@invite)

    render 'invites/show'
  end

  def destroy
    @invite.destroy!

    head :ok
  end

  private

  def fetch_invite
    @invite = Invite.find(params[:id])
  end
end