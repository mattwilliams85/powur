module Anon
  class SessionController < AnonController
    def create
      require_input :email, :password

      @user = User.authenticate(params[:email].downcase, params[:password])
      
      error!(:credentials, :email) unless @user

      login_user(@user, params[:remember_me] == true)

      render 'show'
      # respond_to do |format|
      #   format.html { render text: '' }
      #   format.json { render 'auth/profile/show' }
      # end
    end

    def destroy
      reset_session
      redirect_to root_url
    end
  end
end
