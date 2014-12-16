module Anon
  class PasswordsController < AnonController
    layout 'user'

    before_action :fetch_user_from_token, only: [ :new ]
    helper_method :valid_token?

    def show
    end

    def new
      reset_session if valid_token?
    end

    def create
      require_input :email

      user = User.find_by_email(params[:email]) or
        error!(:email_not_found, :email)

      user.send_reset_password

      confirm :reset_password_request, email: user.email

      render 'anon/session/anonymous'
    end

    def update
      require_input :password, :password_confirm

      unless params[:password] == params[:password_confirm]
        error!(:password_confirm, :password_confirm)
      end

      user = User.find_by_reset_token(params[:token]) or
        error!(:reset_token_invalid)

      error!(:reset_token_expired) if user.reset_token_expired?

      user.password = params[:password]
      user.reset_token = nil
      user.save!

      confirm :reset_password

      render 'anon/session/anonymous'
    end

    protected

    def valid_token?
      !@user.nil? && !@user.reset_token_expired?
    end

    private

    def fetch_user_from_token
      require_input :token

      @user = User.find_by_reset_token(params[:token])

    rescue Errors::InputError
      redirect_to root_url
    end
  end
end
