module Anon
  class SessionController < AnonController
    def create
      require_input :email, :password

      user = User.authenticate(params[:email], params[:password]) ||
             error!(:credentials, :email)

      login_user(user, params[:remember_me] == true)

      respond_to do |format|
        format.html { render text: '' }
        format.json { render 'show' }
      end
    end

    def destroy
      reset_session
      redirect_to root_url
    end
  end
end
