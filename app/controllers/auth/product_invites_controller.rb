module Auth
  class ProductInvitesController < AuthController
    before_action :fetch_product, only: [ :create ]
    before_action :validate_existence, only: [ :create ]
    before_action :fetch_invite, only: [ :show ]

    page
    sort created:  { created_at: :desc },
         customer: 'customers.last_name asc, customers.first_name asc'
    filter :status,
           options:  ProductInvite.statuses.keys,
           required: false

    def index
      @invites = apply_list_query_options(ProductInvite)

      render 'index'
    end

    def show
      render 'show'
    end

    def create
      customer = Customer.create!(customer_input)
      @invite = ProductInvite.create!(
        product_id: @product.id,
        customer:   customer,
        user:       current_user)
      PromoterMailer.product_invitation(@invite).deliver_later

      show
    end

    private

    def customer_input
      allow_input(:first_name, :last_name, :email,
                  :phone, :address, :city, :state, :zip, :notes)
    end

    def validate_existence
      customer = Customer.find_by(email: customer_input['email'])
      error!(:product_invite_exist) if customer
    end

    def fetch_invite
      @invite = ProductInvite.find(params[:id])
    end

    def fetch_product
      @product = Product.find_by(id: params[:product_id])
      not_found!(:product) unless @product
    end
  end
end
