module Anon
  class SessionController < AnonController
    skip_before_action :verify_terms_acceptance

    def create
      require_input :email, :password

      @user = User.authenticate(params[:email], params[:password])

      error!(:credentials, :email) unless @user

      login_user(@user, params[:remember_me] == true)

      respond_to do |format|
        format.html { render 'index/index' }
        format.json { render 'show' }
      end
    end

    def destroy
      reset_session
      redirect_to root_url
    end
  end
end
