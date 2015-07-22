module Admin
  class ProductReceiptsController < AdminController
    page
    sort date_desc: { updated_at: :desc },
         date_asc:  { updated_at: :asc },
         product_id_asc:   { product_id: :asc },
         product_id_desc:  { product_id: :desc },
         id_asc:         { id: :asc },
         id_desc:        { id: :desc },
         amount_asc: { amount: :asc },
         amount_desc: { amount: :desc }


    before_filter :fetch_user, only: [ :index, :create ]

    def index
      scope = ProductReceipt
      scope = @user.product_receipts if @user
      scope = scope.search(params[:search]) if params[:search].present?
      @receipts = apply_list_query_options(scope)
      render 'index'
    end

    def create
      product = Product.find(params[:id])

      product.complimentary_purchase(params[:bonus_volume], @user)

      head 200
    end

    private

    def fetch_user
      @user = User.find_by_id(params[:admin_user_id].to_i)
    end
  end
end
