module Auth
  class InvitesController < AuthController
    before_action :fetch_invite, only: [ :show, :update, :resend, :delete ]
    skip_before_action :authenticate!, only: [ :show ]

    page max_limit: 20
    filter :status,
           options:  [ :pending, :expired ],
           required: false

    def index
      @invites = apply_list_query_options(
        current_user.invites.where('user_id is null').order(expires: :desc))

      render 'index'
    end

    def show
    end

    def create
      error!(:create_invite_not_allowed) unless current_user.partner?
      require_input :first_name, :last_name, :email
      validate_email

      @invite = current_user.create_invite(input)
      @invite.delay.send_sms

      render 'show'
    end

    def resend
      @invite.renew
      current_user.send_invite(@invite)

      render 'show'
    end

    def update
      @invite.update_attributes!(input)

      show
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

    def fetch_invite
      @invite = current_user.invites.find(params[:id])
    end
  end
end
