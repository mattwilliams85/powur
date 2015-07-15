module Admin
  class ProductReceiptsController < AdminController
    page

    before_filter :fetch_user, only: [ :index ]

    def index
      scope = ProductReceipt
      scope = @user.product_receipts if @user
      scope = scope.search(params[:search]) if params[:search].present?
      @receipts = apply_list_query_options(scope)
      render 'index'
    end

    private

    def fetch_user
      @user = User.find_by_id(params[:admin_user_id].to_i)
    end
  end
end
