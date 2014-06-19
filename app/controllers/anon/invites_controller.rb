module Anon

  class InvitesController < AnonController

    before_filter :fetch_invite, only: [ :create, :update ]

    def create
      require_input :code

      session[:code] = @invite.id
      session[:user_id] = nil

      render 'show'
    end

    def update
      require_input :password

      input = params.permit(:first_name, :last_name, :email, :phone, :zip, :password)
      user = @invite.accept(input)

      login_user(user)

      render 'anon/session/show'
    end

    def destroy
      reset_session

      render 'anon/session/anonymous'
    end

  private

    def invalid_code!
      error!(t('errors.invalid_code'), :code)
    end

    def fetch_invite
      @invite = Invite.find_by(id: params[:code], user_id: nil) or invalid_code!
      user = User.find_by_email(@invite.email)
      if user
        @invite.update_attribute(:user_id, user.id)
        invalid_code!
      end
    end

  end

end