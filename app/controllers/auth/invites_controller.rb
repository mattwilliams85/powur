module Auth
  class InvitesController < AuthController
    before_action :fetch_invite, only: [ :show, :renew, :resend, :destroy ]
    skip_before_action :authenticate!, only: [ :show ]

    def index
      @invites = list_criteria

      render 'index'
    end

    def show
    end

    def create
      validate_input

      @invite = current_user.create_invite(input)

      render 'show'
    rescue ActiveRecord::RecordInvalid => e
      raise e unless e.record.errors.first.first == :sponsor
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

    def input
      allow_input(:email, :first_name, :last_name, :phone)
    end

    def validate_input
      require_input :email

      error!(:you_exist, :email) if input['email'] == current_user.email

      existing = User.find_by_email(input['email'])
      return unless existing
      error!(:existing_promoter, :email,
             name: existing.full_name, email: existing.email)
    end

    def list_criteria
      current_user.active_invites.order(created_at: :desc)
    end

    def fetch_invite
      @invite = current_user.invites.find(params[:id])
    end
  end
end
