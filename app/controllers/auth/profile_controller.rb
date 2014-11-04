module Auth
  class ProfileController < AuthController
    before_action :fetch_user, only: [ :show, :update, :update_password ]
    def index
      respond_to do |format|
        format.html
        format.json do
          @user = current_user
          @profile = @user.profile
        end
      end
    end

    def show
    end

    def update
      @user.update_attributes(user_params)
    end

    def update_avatar
      puts params
      if !params[:user]
        error!(t('errors.update_avatar'))
      end
      @user = current_user
      if params[:user][:remove_avatar] == 1
        @user.avatar = ''
      else
        @user.avatar = params[:user][:avatar]
        #@user.avatar = params[:user_avatar]
        # @user.avatar_file_name = params[:user_avatar].original_filename
      end

      if @user.save!
        confirm :update_avatar
      else
        puts 'User wasn\'t saved'
      end
      render 'show'
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

      puts "SET NEW PASSWORD:"
      user.password = params[:new_password]
      user.save!

      confirm :update_password

      respond_to do |format|
        format.js
      end
      #render 'show'
    end

    private

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :phone, :address, :city, :state, :zip, :bio)
    end

    def avatar_params
      params.require(:user).permit(:user_avatar, :authenticity_token)
    end

    def fetch_user
      @user = current_user
    end
  end
end
