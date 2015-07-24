module Anon
  class InvitesController < AnonController
    before_action :fetch_invite, only: [ :update, :validate ]

    def update
      input = invite_input

      # for ToS, we store the version number the user last agreed to
      # so we change the 'true' value to the version of the ToS when they signed up:
      input[:tos] = input[:tos_version] if input[:tos] == true

      begin
        user = @invite.accept(input)
      rescue Gibbon::MailChimpError => e
        Airbrake.notify(e)
      end

      if user.errors.empty?
        PromoterMailer.notify_upline(user).deliver_later
        PromoterMailer.welcome_new_user(user).deliver_later

        # Sign in new user and return session
        user = User.authenticate(params[:email], params[:password])
        login_user(user, params[:remember_me] == true)

        render 'anon/session/show'
      else
        render json: { errors: user.errors.messages }
      end
    end

    def destroy
      reset_session

      render 'anon/session/anonymous'
    end

    def validate
      render 'show'
    end

    private

    def invalid_code!
      error!(:invalid_code, :code)
    end

    def fetch_invite
      @invite = Invite.find_by(id: params[:code], user_id: nil) || invalid_code!
      user = User.find_by_email(@invite.email.downcase)
      return unless user
      @invite.update_attribute(:user_id, user.id)
      invalid_code!
    end

    def invite_input
      params.permit(:first_name, :last_name, :email, :code,
                    :password, :password_confirmation,
                    :address, :city, :phone, :zip, :state, :country,
                    :tos, :tos_version, :communications)
    end
  end
end
