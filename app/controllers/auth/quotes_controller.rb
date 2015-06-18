module Auth
  class QuotesController < AuthController
    before_action :verify_rank, except: [ :index, :show ]
    before_action :fetch_user!
    before_action :fetch_quotes, only: [ :index ]
    before_action :fetch_quote,
                  only: [ :show, :update, :destroy, :resend, :submit ]

    page
    sort created:  { created_at: :desc },
         customer: 'customers.last_name asc, customers.first_name asc'
    filter :status,
           options:  Quote.statuses.keys,
           required: false

    def index
      @quotes = apply_list_query_options(@quotes)

      render 'index'
    end

    def show
      render 'show'
    end

    def create
      customer = Customer.create!(customer_input)
      @quote = Quote.create!(
        product_id: product.id,
        customer:   customer,
        user:       current_user,
        data:       quote_input)
      @quote.input!

      show
    end

    def update
      @quote.customer.update_attributes!(customer_input)
      @quote.update(data: quote_input)
      @quote.input!

      show
    end

    def destroy
      error!(:delete_quote) if @quote.submitted_at?

      @quote.destroy

      head :no_content
    end

    def resend
      @quote.email_customer if @quote.can_email?

      show
    end

    def submit
      error!(:cannot_submit_quote) unless @quote.can_submit?

      @quote.submit!
      @quote.email_customer if @quote.can_email?

      show
    end

    private

    def fetch_quotes
      @quotes = Quote
        .includes(:customer, :user, :product)
        .references(:customer, :user, :product)
      @quotes = @quotes.where(user_id: @user.id) if @user
      @quotes = @quotes.customer_search(params[:search]) if params[:search]
    end

    def fetch_quote
      @quote =
        if admin?
          Quote.find_by(id: params[:id].to_i)
        else
          Quote.where(user_id: @user.id, id: params[:id].to_i).first
        end
      not_found!(:quote) unless @quote
    end

    def customer_input
      allow_input(:first_name, :last_name, :email,
                  :phone, :address, :city, :state, :zip, :notes)
    end

    def product
      @product ||= Product.default
    end

    def quote_input
      allow_input(*product.quote_fields.map(&:name))
    end
  end
end
