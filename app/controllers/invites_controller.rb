class InvitesController < AuthController

  before_filter :fetch_invite, only: [ :renew, :resend, :destroy ]
  skip_before_filter :authenticate!, only: [ :show ]

  def index
    @invites = list_criteria
  end

  def search
    list_criteria.search(params[:q])

    render 'index'
  end

  def show
    @invite = Invite.find(params[:id])

    render 'show'
  end

  def create
    input = params.permit(:email, :first_name, :last_name, :phone)

    if input[:email] == current_user.email
      error!(t('errors.you_exist'), :email)
    end

    if (existing = User.find_by_email(input[:email]))
      msg = t('errors.existing_promoter', 
        name:   existing.full_name, 
        email:  existing.email)
      error!(msg, :email)
    end

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

  def list_criteria
    current_user.active_invites.order(created_at: :desc)
  end

  def fetch_invite
    @invite = current_user.invites.find(params[:id])
  end
end