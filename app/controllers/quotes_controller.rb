class QuotesController < AnonController
  before_action :fetch_sponsor, only: [ :new, :show, :create, :update ]

  def new
    sponsor? || redirect_to(root_url)
  end

  def details
  end

  def show
    respond_to do |format|
      format.html { render 'new' }
      format.json { render quote? ? 'show' : 'new' }
    end
  end

  def create
    require_input :first_name, :last_name, :email, :sponsor, :phone

    not_found!(:sponsor, params[:sponsor]) unless sponsor?

    if quote_from_email?
      error!(:quote_exists, :email, email: params[:email])
    end

    customer = Customer.create!(customer_input)
    @quote = @sponsor.quotes.create!(
      quote_input.merge(customer: customer, product: Product.default))

    render 'show'
  end

  def update
    require_input :quote

    quote? || not_found!(:quote, params[:quote])

    quote.customer.update_attributes!(customer_input)
    quote.update_attributes!(quote_input)

    render 'show'
  end

  def resend
    require_input :email, :product_id

    quote_from_email? ||
      error!(:quote_not_found, :email, email: params[:email])

    confirm :quote_resent

    render 'new'
  end

  protected

  def fetch_sponsor
    @sponsor = User.find_by_url_slug(params[:sponsor])
  end

  def sponsor?
    !@sponsor.nil?
  end

  def quote
    @quote ||= params[:quote] ? Quote.find_by_url_slug(params[:quote]) : nil
  end

  def quote?
    !!quote
  end

  private

  def product
    @product ||= Product.default
  end

  def customer_input
    allow_input(
      :first_name, :last_name, :email, :phone,
      :address, :city, :state, :zip)
  end

  def quote_input
    allow_input(*product.quote_fields.map(&:name))
  end

  def quote_from_email
    @quote ||= Quote.where(product_id: Product.default.id)
               .joins(:customer).where('customers.email' => params[:email]).first
  end

  def quote_from_email?
    !!quote_from_email
  end
end
