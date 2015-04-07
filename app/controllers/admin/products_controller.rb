module Admin
  class ProductsController < AdminController
    before_action :fetch_product, only: [ :show, :destroy, :update ]

    def index
      respond_to do |format|
        format.html
        format.json do
          @products = Product.order(:name)
        end
      end
    end

    def create
      require_input :name
      @product = Product.create!(input)
      head 200
    end

    def update
      @product.update_attributes!(input)

      head 200
    end

    def show
    end

    def destroy
      @product.destroy

      @products = Product.order(:name)

      head 200
    rescue ActiveRecord::InvalidForeignKey
      error!(:delete_product)
    end

    private

    def input
      allow_input(:name, :bonus_volume, :commission_percentage)
    end

    def fetch_product
      @product = Product.find(params[:id].to_i)
    end
  end
end
