module Admin
  class ProductsController < AdminController
    before_action :fetch_product, only: [ :show, :destroy, :update ]

    page
    filter :university_classes,
           url:        -> { products_path },
           scope_opts: { type: :boolean },
           required:   false

    def index
      @products = apply_list_query_options(Product)

      render 'index'
    end

    def create
      require_input :name
      @product = Product.create!(input)

      show
    end

    def update
      @product.update_attributes!(input)

      show
    end

    def show
      render 'show'
    end

    def destroy
      @product.destroy
      @products = Product.order(:name)

      index
    rescue ActiveRecord::InvalidForeignKey
      error!(:delete_product)
    end

    private

    def input
      allow_input(
        :name, :bonus_volume, :commission_percentage,
        :is_university_class, :description, :long_description,
        :image_original_path, :prerequisite_id)
    end

    def fetch_product
      @product = Product.find(params[:id].to_i)
    end
  end
end
