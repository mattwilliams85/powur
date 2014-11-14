module Auth
  class ProfileController < AuthController
    before_action :fetch_user, only: [ :show, :update, :update_avatar,
                                       :update_password ]

    def show
      @user = current_user
      @profile = @user.profile
      respond_to do |format|
        format.html
        format.json do
          @user = current_user
          @profile = @user.profile
        end
      end
    end

    def update
      @user.update_attributes(user_params)
    end

    def update_avatar
      @user.avatar = params[:user][:avatar]
      @user.save
      redirect_to profile_path
    end

    def update_password
      require_input :current_password, :new_password, :new_password_confirm
      user = current_user
      unless user && user.password_match?(params['current_password'])
        error!(t('errors.password_update'), :current_password)
      end

      unless params[:new_password] == params[:new_password_confirm]
        error!(t('errors.password_confirm'), :new_password_confirm)
      end

      user.password = params[:new_password]
      user.save!

      confirm :update_password

      # respond_to do |format|
      #   format.js
      # end
    end

    private

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email,
                                   :phone, :address, :city, :state,
                                   :zip, :bio,:avatar_file_name, :avatar)
    end

    # def avatar_params
    #   params.require(:user).permit(:avatar,:avatar_file_name)
    # end

   def avatar_params
        params.require(:user).permit(:avatar_file_name)
    end

    def fetch_user
      @user = current_user
    end
  end
end
