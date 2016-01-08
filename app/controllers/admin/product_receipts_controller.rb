module Admin
  class ProductReceiptsController < AdminController
    page
    sort date_desc:       { updated_at: :desc },
         date_asc:        { updated_at: :asc },
         product_id_asc:  { product_id: :asc },
         product_id_desc: { product_id: :desc },
         id_asc:          { id: :asc },
         id_desc:         { id: :desc },
         amount_asc:      { amount: :asc },
         amount_desc:     { amount: :desc }

    before_filter :fetch_user, only: [ :index, :create ]
    before_filter :fetch_receipt, only: [ :refund ]

    def index
      scope = ProductReceipt
      scope = @user.product_receipts if @user
      scope = scope.search(params[:search]) if params[:search].present?
      @receipts = apply_list_query_options(scope)
      render 'index'
    end

    def create
      product = Product.find(params[:id])

      product.complimentary_purchase(@user)
      Rank.rank_user(@user.id)

      update_mailchimp if product.slug == 'partner'

      head 200
    end

    def refund
      @product_receipt.touch(:refunded_at)

      render :show
    end

    private

    def fetch_user
      @user = User.find_by_id(params[:admin_user_id].to_i)
    end

    def fetch_receipt
      @product_receipt = ProductReceipt.find_by(id: params[:id].to_i)
    end

    def update_mailchimp
      @user.mailchimp_update_subscription
    rescue Gibbon::MailChimpError => e
      Airbrake.notify(e)
    end

  end
end
