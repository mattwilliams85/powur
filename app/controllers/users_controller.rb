class UsersController < ApplicationController

  def accept_invite
    @invite = Invite.find_by(id: params[:code]) or invalid_code!

    render 'registration'
  end

  def create
    invite = Invite.find_by(id: params[:code]) or invalid_code!

    input = params.permit(:first_name, :last_name, :email, :phone, :zip)
    
    user = User.new(input)
    user.password = params[:password]
    user.save!

    login_user(user)

    render 'show'
  end

  private

  def invalid_code!
    error!(t('errors.invalid_code'), :code)
  end

end
