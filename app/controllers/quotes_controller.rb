class QuotesController < ApplicationController
  layout 'user'

  before_filter :fetch_promoter, only: [ :new, :show, :create, :update ]

  def new
    promoter? or redirect_to root_url
  end

  def details
  end

  def show
    render customer? ? 'show' : 'new'
  end

  def create
    require_input :first_name, :last_name, :email, :phone, :promoter

    promoter? or not_found!(:promoter, params[:promoter])

    @customer = @promoter.customers.create!(input)

    render 'show'
  end

  def update
    require_input :quote_slug

    customer? or not_found!(:quote, params[:quote])

    customer.update_attributes!(input)

    render 'show'
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
  
end