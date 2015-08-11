module Anon
  class PasswordsController < AnonController
    def show
    end

    def create
      require_input :email

      user = if SystemSettings.case_sensitive_auth
               User.find_by(email: params[:email])
             else
               User.where('lower(email) = ?', params[:email].downcase).first
             end

      user.send_reset_password if user

      head 200
    end

    def update
      require_input :password, :password_confirm, :token

      unless params[:password] == params[:password_confirm]
        error!(:password_confirm, :password_confirm)
      end
      user = User.find_by_reset_token(params[:token])
      return render json:   {},
                    status: :unauthorized if !user || user.reset_token_expired?

      reset_session

      user.password = params[:password]
      user.reset_token = nil
      user.save!

      confirm :reset_password

      render 'anon/session/anonymous'
    end

    def validate_reset_token
      if User.find_by_reset_token(params[:token])
        head 200
      else
        head :unauthorized
      end
    end
  end
end
