module Auth
  class QuotesController < AuthController
    before_action :fetch_quote, only: [ :show, :update, :destroy, :resend ]
    helper QuotesJson

    def index
      @quotes = quote_list

      render 'index'
    end

    def search
      @quotes = quote_list.customer_search(params[:search])

      render 'index'
    end

    def show
      render 'show'
    end

    def create
      customer = Customer.create!(customer_input)
      @quote = Quote.create!(
        product_id: product_id,
        customer:   customer,
        user:       current_user,
        data:       quote_input)

      @quote.email_customer if @quote.can_email?
      show
    end

    def update
      @quote.customer.update_attributes!(customer_input)
      @quote.update_attributes!(quote_input)

      confirm :update, entity: @quote.customer.full_name

      show
    end

    def resend
      # TODO: error msg on no email
      @quote.email_customer if @quote.can_email?

      show
    end

    def destroy
      @quote.destroy

      confirm :delete, entity: @quote.customer.full_name

      index
    end

    private

    def product
      @product ||= Product.default
    end

    def product_id
      product.id
    end

    def customer_input
      allow_input(
        :first_name, :last_name, :email, :phone,
        :address, :city, :state, :zip)
    end

    def quote_input
      allow_input(*product.quote_fields.map(&:name))
    end

    def fetch_quote
      @quote = current_user.quotes.find_by(id: params[:id]) ||
        not_found!(:quote)
    end

    def quote_list
      current_user.quotes
        .includes(:customer, :user, :product)
        .references(:customer, :user, :product)
        .customer_search(params[:search])
        .order(created_at: :desc)
    end
  end
end
