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

    user = User.find_by_reset_token(params[:token]) or
      error!(t('errors.reset_token_invalid'))

    error!(t('errors.reset_token_expired')) if user.reset_token_expired?

    user.password = params[:password]
    user.reset_token = nil
    user.save!

    render json: {}
  end
end