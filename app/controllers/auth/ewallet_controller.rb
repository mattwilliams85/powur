module Auth
  class EwalletController < AuthController
    include EwalletDSL
    before_action :fetch_user

    def index
      respond_to do |format|
        format.html do
        end
        format.json do
        end
      end
    end

    def account_details
      @ewallet_account_details = get_ewallet_customer_details(@user)
    end

    def fetch_user
      @user = current_user
    end
  end
end
