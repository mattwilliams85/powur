module Anon
  class InvitesController < AnonController
    before_action :fetch_invite, only: [ :update, :show ]

    def show
      @invite.touch(:last_viewed_at)
    end

    def update
      require_input :first_name, :last_name, :email, :password,
                    :phone, :state, :zip

      input = invite_input

      # for ToS, we store the version number the user last agreed to
      # so we change the 'true' value to the version of the ToS when they signed up:
      input[:tos] = input[:tos_version] if input[:tos] == true

      user = @invite.accept(input)

      User.delay.validate_phone_number!(user.id)
      PromoterMailer.notify_upline(user).deliver_later
      PromoterMailer.welcome_new_user(user).deliver_later
      subscribe_to_mailchimp_list(user) unless Rails.env.development?

      # Sign in new user and return session
      user = User.authenticate(params[:email], params[:password])
      login_user(user, params[:remember_me] == true)

      render 'anon/session/show'
    end

    private

    def fetch_invite
      @invite = Invite.find(params[:id])
      not_found!(:invite) unless @invite.pending?
    end

    def invite_input
      params.permit(:first_name, :last_name, :email,
                    :password, :password_confirmation,
                    :address, :city, :phone, :zip, :state, :country,
                    :tos, :tos_version, :communications)
    end

    def subscribe_to_mailchimp_list(user)
      user.mailchimp_subscribe
    rescue Gibbon::MailChimpError => e
      Airbrake.notify(e)
    end
  end
end
