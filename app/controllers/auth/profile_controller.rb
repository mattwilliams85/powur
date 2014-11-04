module Auth
  class ProfileController < AuthController
    before_action :fetch_user, only: [ :show, :update, :update_avatar,
                                       :update_password ]


    def show
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
      @user = current_user
      if params[:user][:remove_avatar] == 1
        @user.avatar = ''
        @user.avatar_file_name = ' '
      elsif params[:user].key?(:avatar)
        @user.avatar = params[:user][:avatar]
        @user.avatar_file_name = params[:user][:avatar].original_filename
      end

      if @user.save!
        confirm :update_avatar
      else
        puts 'User wasn\'t saved'
      end
      redirect_to('show')
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
                                   :zip, :bio)
    end

    def avatar_params
      params.require(:user).permit(:user_avatar, :authenticity_token)
    end

    def fetch_user
      @user = current_user
    end
  end
end
