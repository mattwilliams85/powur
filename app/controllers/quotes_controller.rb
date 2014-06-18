class QuotesController < ApplicationController
  layout 'user'

  before_filter :fetch_sponsor, only: [ :new, :show, :create, :update ]

  def new
    sponsor? or redirect_to root_url
  end

  def details
  end

  def show
    respond_to do |format|
      format.html { render 'new' }
      format.json { render customer? ? 'show' : 'new' }
    end
  end

  def create
    require_input :first_name, :last_name, :email, :phone, :sponsor

    not_found!(:sponsor, params[:sponsor]) unless sponsor?

    if quote_from_email?
      error!(t('errors.quote_exists', email: params[:email]), :email)
    end

    customer = Customer.create!(customer_input)
    @quote = @sponsor.quotes.create!(
      quote_input.merge(customer: customer, product: Product.default))

    render 'show'
  end

  def update
    require_input :quote

    customer? or not_found!(:quote, params[:quote])

    customer.update_attributes!(input)

    render 'show'
  end

  def resend
    require_input :email, :product_id

    quote_from_email? or 
      error!(t('errors.quote_not_found', email: params[:email]), :email)

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

  def customer
    @customer ||= params[:quote] ? Customer.find_by_url_slug(params[:quote]) : nil
  end

  def customer?
    !!customer
  end

  private

  def customer_input
    allow_input(
      :first_name, :last_name, :email, :phone, 
      :address, :city, :state, :zip)
  end

  def quote_input
    allow_input(Product.default.quote_data)
  end

  def quote_from_email
    @quote ||= Quote.where(product_id: Product.default.id).
      joins(:customer).where('customers.email' => params[:email]).first
  end

  def quote_from_email?
    !!quote_from_email
  end
  
end