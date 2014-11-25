module Auth
  class EmpowerMerchantController < AuthController
    include EmpowerMerchantDSL
    before_action :fetch_user

    def index
      respond_to do |format|
        format.html do
        end
        format.json do
        end
      end
    end

    def sandbox
      # sandbox stuff
      conn = connect
    end

    def fetch_user
      @user = current_user
    end
  end
end
