class SessionController < ApplicationController
  layout 'user'

  before_filter :fetch_invite, only: [ :accept_invite, :register ]

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

  def accept_invite
    require_input :code

    session[:code] = @invite.id
    session[:user_id] = nil

    render 'registration'
  end

  def register
    require_input :password

    input = params.permit(:first_name, :last_name, :email, :phone, :zip, :password)
    user = @invite.accept(input)

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

  def fetch_invite
    @invite = Invite.find_by(id: params[:code], user_id: nil) or invalid_code!
    user = User.find_by_email(@invite.email)
    if user
      @invite.update_attribute(:user_id, user.id)
      invalid_code!
    end
  end

end