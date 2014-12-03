module Anon
  class SessionController < AnonController
    layout 'user'

    def index
      render 'index'
    end

    def create
      require_input :email, :password

      user = User.authenticate(params[:email], params[:password]) ||
             error!(t('errors.credentials'), :email)

      login_user(user)

      render 'show'
    end

    def destroy
      reset_session

      redirect_to root_url
    end
  end
end
