module Auth
  class ProfileController < AuthController
    include EwalletDSL

    skip_before_action :verify_terms_acceptance, only: [:show, :update]

    before_action :fetch_user, only: [ :show, :update, :update_avatar,
                                       :update_password, :create_ewallet ]

    def show
      @profile = @user.profile
      @auto_login_url = build_auto_login_url(@user)
      @ewallet_details = get_ewallet_customer_details(@user)

      render :show
    end

    def create_ewallet
      find_or_create_ipayout_account(@user)

      show
    end

    def update
      if @user.update_attributes(user_params)
        User.delay.process_image_original_path!(@user.id) if user_params['image_original_path']
      end

      show
    end

    def update_avatar
      @user.avatar = params[:user][:avatar]
      @user.save!

      show
    end

    def update_password
      require_input :current_password, :new_password, :new_password_confirm

      unless @user.password_match?(params['current_password'])
        error!(:password_update, :current_password)
      end

      unless params[:new_password] == params[:new_password_confirm]
        error!(:password_confirm, :new_password_confirm)
      end

      @user.password = params[:new_password]
      @user.save!

      confirm :update_password

      show
    end

    private

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email,
                                   :phone, :address, :city, :state, :zip,
                                   :bio, :twitter_url, :facebook_url,
                                   :image_original_path, :avatar, :tos,
                                   :watched_intro,
                                   :allow_sms, :allow_system_emails,
                                   :allow_corp_emails,
                                   :mark_notifications_as_read)
    end

    def avatar_params
      params.require(:user).permit(:avatar_file_name)
    end

    def fetch_user
      @user = current_user
    end
  end
end
