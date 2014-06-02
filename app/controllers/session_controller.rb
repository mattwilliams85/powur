class SessionController < ApplicationController
  layout 'user'

  def index
    render 'index'
  end

  def create
    require_input :email, :password

    user = User.authenticate(params[:email], params[:password]) or
      error!(t('errors.credentials'), :email)

    login_user(user)

    render 'show'
  end

  def destroy
    reset_session

    redirect_to root_url
  end

  def reset_password
    require_input :email

    user = User.find_by_email(:email) or error!(t('errors.email_not_found'), :email)

    user.send_reset_password

    index
  end

  def accept_invite
    require_input :code

    @invite = Invite.find_by(id: params[:code]) or invalid_code!

    # reset_session: TODO, reset_session without clearing CSRF
    session[:code] = @invite.id

    render 'registration'
  end

  def register
    invite = Invite.find_by(id: params[:code]) or invalid_code!

    input = params.permit(:first_name, :last_name, :email, :phone, :zip, :password)

    user = invite.invitor.add_invited_user(input)

    login_user(user)

    render 'show'
  end

  def clear_code
    reset_session

    render 'anonymous'
  end

  private

  def invalid_code!
    error!(t('errors.invalid_code'), :code)
  end

end