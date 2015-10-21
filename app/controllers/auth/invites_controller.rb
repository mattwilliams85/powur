module Auth
  class InvitesController < AuthController
    before_action :fetch_invite, only: [ :show, :resend, :delete ]
    skip_before_action :authenticate!, only: [ :show ]

    def index
      current_user.reconcile_invites
      @invites = list_criteria

      render 'index'
    end

    def show
    end

    def create
      require_input :first_name, :last_name, :email

      validate_email
      validate_max_invites

      @invite = current_user.create_invite(input)
      @invite.delay.send_sms

      current_user.reconcile_invites if current_user.available_invites < 1

      render 'show'
    end

    def resend
      @invite.renew
      current_user.send_invite(@invite)

      render 'show'
    end

    def delete
      @invite.destroy!

      index
    end

    private

    def input
      allow_input(:email, :first_name, :last_name, :phone)
    end

    def validate_uniq_email
      existing = User.find_by_email(input['email'])
      return unless existing
      error!(:existing_promoter, :email,
             name: existing.full_name, email: existing.email)
    end

    def validate_email
      return unless params[:email].present?
      params[:email].downcase! unless SystemSettings.case_sensitive_auth

      error!(:you_exist, :email) if input['email'] == current_user.email
      validate_uniq_email
    end

    def validate_max_invites
      max_exceeded =
        current_user.limited_invites? && current_user.available_invites < 1
      error!(:exceeded_max_invites) if max_exceeded
    end

    def list_criteria
      current_user.invites.where('user_id is null').order(created_at: :desc)
    end

    def fetch_invite
      @invite = current_user.invites.find(params[:id])
    end
  end
end
