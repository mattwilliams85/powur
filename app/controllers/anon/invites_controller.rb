module Anon
  class InvitesController < AnonController
    include EwalletDSL
    before_action :fetch_invite, only: [ :create, :update ]

    def create
      require_input :code

      session[:code] = @invite.id
      session[:user_id] = nil

      render 'show'
    end

    def update
      require_input :password
      input = params.permit(:first_name,
                            :last_name,
                            :email,
                            :password,
                            :phone,
                            :zip)
      user = @invite.accept(input)
      find_or_create_ipayout_account(user)
      PromoterMailer.notify_upline(user).deliver_later
      PromoterMailer.welcome_new_user(user).deliver_later

      # Set the URL slug of the new user
      # (the SecureRandom number is to safeguard against users with the same name)
      user.url_slug = "#{user.first_name}-#{user.last_name}-#{SecureRandom.random_number(100)}"

      login_user(user)
      render 'anon/session/show'
    end

    def destroy
      reset_session

      render 'anon/session/anonymous'
    end

    private

    def invalid_code!
      error!(:invalid_code, :code)
    end

    def fetch_invite
      @invite = Invite.find_by(id: params[:code], user_id: nil) || invalid_code!
      user = User.find_by_email(@invite.email)
      if user
        @invite.update_attribute(:user_id, user.id)
        invalid_code!
      end
    end
  end
end
