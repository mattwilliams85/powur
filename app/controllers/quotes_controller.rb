class QuotesController < ApplicationController
  layout 'user'

  before_filter :fetch_promoter, only: [ :new, :show, :create, :update ]

  def new
    promoter? or redirect_to root_url
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
    require_input :first_name, :last_name, :email, :phone, :promoter

    not_found!(:promoter, params[:promoter]) unless promoter?

    if quote_from_email?
      error!(t('errors.quote_exists', email: params[:email]), :email)
    end

    @customer = @promoter.customers.create!(input)

    render 'show'
  end

  def update
    require_input :quote

    customer? or not_found!(:quote, params[:quote])

    customer.update_attributes!(input)

    render 'show'
  end

  def resend
    require_input :email

    quote_from_email? or 
      error!(t('errors.quote_not_found', email: params[:email]), :email)

    confirm :quote_resent

    render 'new'
  end

  protected

  def fetch_promoter
    @promoter = User.find_by_url_slug(params[:promoter])
  end

  def promoter?
    !@promoter.nil?
  end

  def customer
    @customer ||= params[:quote] ? Customer.find_by_url_slug(params[:quote]) : nil
  end

  def customer?
    !!customer
  end

  private

  def input
    allow_input(
      :first_name, :last_name, :email, :phone, :address, 
      :city, :state, :zip, :roof_material, :roof_age)
  end

  def quote_from_email
    @quote ||= Customer.find_by_email(params[:email])
  end

  def quote_from_email?
    !!quote_from_email
  end
  
end