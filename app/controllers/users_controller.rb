class UsersController < ApplicationController

  def accept_invite
    @invite = Invite.find_by(id: params[:code]) or
      error!(t('errors.invalid_code'), :code)

    render 'registration'
  end

  def create
    
  end

end
