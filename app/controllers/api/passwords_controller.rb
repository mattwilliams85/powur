module Api
  class PasswordsController < ApiController
    skip_before_action :authenticate!

    def create
      user = User.find_by_email(params[:email])

      user.send_reset_password if user

      render 'api/root/show'
    end
  end
end
