module Anon
  class PasswordsController < AnonController
    def show
    end

    def create
      require_input :email
      user = User.find_by_email(params[:email])
      user.send_reset_password if user

      head 200
    end

    def update
      require_input :password, :password_confirm, :token

      unless params[:password] == params[:password_confirm]
        error!(:password_confirm, :password_confirm)
      end
      user = User.find_by_reset_token(params[:token])
      head :unauthorized if !user || user.reset_token_expired?

      reset_session

      user.password = params[:password]
      user.reset_token = nil
      user.save!

      confirm :reset_password

      render 'anon/session/anonymous'
    end
  end
end
