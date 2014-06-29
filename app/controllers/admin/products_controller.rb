module Admin

  class ProductsController < AdminController

    before_filter :fetch_product, only: [ :show, :destroy, :update ]

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

      render 'show'
    end

    def update
      @product.update_attributes!(input)

      render 'show'
    end

    def show
    end

    def destroy
      @product.destroy

      @products = Product.order(:name)

      render 'index'
    rescue ActiveRecord::InvalidForeignKey
      error!(t('errors.delete_product'))
    end

    private

    def input
      allow_input(:name, :commissionable_volume, :commission_percentage, quote_data: [])
    end

    def fetch_product
      @product = Product.find(params[:id].to_i)
    end

  end


end
