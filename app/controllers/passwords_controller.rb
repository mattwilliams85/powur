class PasswordsController < ApplicationController

  layout 'user'

  def show
  end

  def create
    require_input :email

    user = User.find_by_email(params[:email]) or 
      error!(t('errors.email_not_found'), :email)

    user.send_reset_password

    render json: {}
  end

  def update
    require_input :password, :password_confirm, :token


  end
end