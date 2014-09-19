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
      input = allow_input(:first_name, :last_name, 
        :email, :phone, :address, :city, :state, :zip)
      
      @user.update_attributes!(input)
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
