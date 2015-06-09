module Auth
  class ProfileController < AuthController
    include EwalletDSL

    skip_before_action :verify_terms_acceptance, only: [:show, :update]

    before_action :fetch_user, only: [ :show, :update, :update_avatar,
                                       :update_password ]

    def show
      @user = current_user
      @profile = @user.profile
    end

    def ewallet_details
      @auto_login_url = build_auto_login_url(current_user)
      @ewallet_details = get_ewallet_customer_details(current_user)
      # User has to finish required class to have an iPayout account
      head :precondition_failed if @ewallet_details[:status] == 'error'
    end

    def update
      user_params['email'].downcase! if user_params['email']

      if @user.update_attributes(user_params)
        User.delay.process_image_original_path!(@user.id) if user_params['image_original_path']
      end

      render 'show'
    end

    def update_avatar
      @user.avatar = params[:user][:avatar]
      @user.save

      redirect_to profile_path
    end

    def update_password
      @ewallet_details = get_ewallet_customer_details(@user)
      require_input :current_password, :new_password, :new_password_confirm
      user = current_user
      unless user && user.password_match?(params['current_password'])
        error!(:password_update, :current_password)
      end

      unless params[:new_password] == params[:new_password_confirm]
        error!(:password_confirm, :new_password_confirm)
      end

      user.password = params[:new_password]
      user.save!

      confirm :update_password

      render 'show'
    end

    private

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email,
                                   :phone, :address, :city, :state, :zip,
                                   :bio, :twitter_url, :facebook_url,
                                   :image_original_path, :avatar, :tos)
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
