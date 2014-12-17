module Anon
  class SessionController < AnonController
    layout 'user'

    before_filter :redirect_if_logged_in, except: [:destroy]

    def index
      render 'index'
    end

    def create
      require_input :email, :password

      user = User.authenticate(params[:email], params[:password]) ||
             error!(:credentials, :email)

      login_user(user, params[:remember_me] == 'on')

      render 'show'
    end

    def destroy
      reset_session

      redirect_to root_url
    end

    private
    def redirect_if_logged_in
      redirect_to dashboard_path if logged_in?
    end
  end
end
