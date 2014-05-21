class SessionController < ApplicationController

  def create
    require_input :email, :password

    user = User.authenticate(params[:email], params[:password])
    error!(t('errors.credentials'), :email) unless user

    reset_session
    session[:user_id] = user.id
    redirect_to dashboard_url
  end

  def destroy
  end
end