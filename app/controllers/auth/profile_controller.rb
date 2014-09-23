module Auth
  class ProfileController < AuthController

    before_action :fetch_user, only: [ :show, :update, :update_password ]
    def index
      respond_to do |format|
        format.html
        format.json do
          @user = current_user
        end
      end
    end

    def show

    end

    def update
      input = allow_input(:first_name, :last_name, :email, :phone, 
                          :address, :city, :state, :zip, :provider, 
                          :monthly_bill, :bio, :twitter_url, 
                          :linkedin_url, :facebook_url, :avatar)

      @user.update_attributes!(input)
      render 'show'
    end

    def update_avatar

      if !params[:user]
        error!(t('errors.update_avatar'))
      end

      if params[:user][:remove_avatar] == 1
        @user.avatar = ""
      else        
        @user = current_user
        @user.avatar = params[:user][:avatar]
      end
      
      if @user.save!
        confirm :update_password
      end

      redirect_to action: "show"
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

      render 'show'
    end

    private

    def fetch_user
      @user = current_user
    end

  end
end
