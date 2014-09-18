module Auth
  class ProfileController < AuthController

    before_action :fetch_user, only: [ :show, :update ]
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

    private

    def fetch_user
      @user = current_user  
    end

  end
end
