class InvitesController < AuthController

  before_filter :fetch_invite, only: [ :renew, :resend, :destroy ]
  skip_before_filter :authenticate!, only: [ :show ]

  def index
    @invites = current_user.active_invites.order(created_at: :desc)

    render 'index'
  end

  def show
    @invite = Invite.find(params[:id])

    render 'show'
  end

  def create
    input = params.permit(:email, :first_name, :last_name, :phone)

    @invite = current_user.create_invite(input)

    render 'show'
  rescue ActiveRecord::RecordInvalid => e
    raise e unless e.record.errors.first.first == :invitor
    error!(e.message)
  end

  def resend
    @invite.renew
    current_user.send_invite(@invite)

    render 'show'
  end

  def destroy
    @invite.destroy!

    index
  end

  private

  def fetch_invite
    @invite = current_user.invites.find(params[:id])
  end
end