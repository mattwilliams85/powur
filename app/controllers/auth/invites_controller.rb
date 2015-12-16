module Auth
  class InvitesController < AuthController
    before_action :fetch_invite,
                  only: [ :show, :update, :resend, :delete, :email ]
    skip_before_action :authenticate!, only: [ :show ]

    page max_limit: 20
    filter :status,
           options:  [ :pending ],
           required: false

    def index
      @invites = apply_list_query_options(
        current_user.invites.where('user_id is null').order(created_at: :desc))

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
      current_user.send_invite(@invite)

      index
    end

    def update
      resend_invite = params.delete(:resend)
      @invite.update_attributes!(input)

      current_user.send_invite(@invite) if resend_invite

      index
    end

    def delete
      @invite.destroy!

      index
    end

    private

    def input
      allow_input(:email, :first_name, :last_name, :phone)
    end

    def validate_user_existence
      existing = User.find_by_email(input['email'])
      return unless existing
      error!(:existing_promoter, :email,
             name: existing.full_name, email: existing.email)
    end

    def warn_invite_existence
      invite = Invite.find_by(email: params[:email])
      warn!(:invite_exists, :email,
            sponsor: invite.sponsor.full_name, email: invite.email) if invite
    end

    def validate_email
      return unless params[:email].present?
      params[:email].downcase! unless SystemSettings.case_sensitive_auth

      error!(:you_exist, :email) if input['email'] == current_user.email
      validate_user_existence
      warn_invite_existence unless params[:confirm_existing_email].to_i == 1
    end

    def fetch_invite
      @invite = current_user.invites.find(params[:id])
    end
  end
end
