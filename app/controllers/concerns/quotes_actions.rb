module QuotesActions
  extend ActiveSupport::Concern

  included do
    before_action :fetch_quote, only: [ :show, :update, :destroy, :resend, :submit ]

    page
    sort created:  { created_at: :desc },
         customer: 'customers.last_name asc, customers.first_name asc'
  end

  def index
    @list_query = list_query.customer_search(params[:search]) if params[:search]
    @quotes = apply_list_query_options(list_query)

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
    @quote.update(data: quote_input)

    confirm :update, entity: @quote.customer.full_name

    show
  end

  def resend
    # TODO: error msg on no email
    @quote.email_customer if @quote.can_email?

    show
  end

  def submit
    error!(:cannot_submit_quote) if @quote.submitted?

    @quote.submit!

    show
  end


  def destroy
    error!(:delete_quote) if @quote.submitted?

    @quote.destroy

    confirm :delete, entity: @quote.customer.full_name

    index
  end

  private

  def list_query
    @list_query ||= begin
      current_user.quotes
      .includes(:customer, :user, :product)
      .references(:customer, :user, :product)
    end
  end

  def fetch_quote
    @quote = current_user.quotes.find_by(id: params[:id]) ||
             not_found!(:quote)
  end

  def customer_input
    allow_input(
      :first_name, :last_name, :email, :phone,
      :address, :city, :state, :zip)
  end

  def quote_input
    allow_input(*product.quote_fields.map(&:name))
  end

  def product
    @product ||= Product.default
  end

  def product_id
    product.id
  end

end
