module Admin
  class UserPurchasesController < AdminController
    def index
      @user = User.find(params[:admin_user_id].to_i)
    end
  end
end
