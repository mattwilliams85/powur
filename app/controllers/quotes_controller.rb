class QuotesController < ApplicationController
  layout 'user'

  helper_method :promoter?, :promoter

  def new
  end

  def details
  end

  def show
    render self.customer? ? 'show' : 'new'
  end

  def create
    require_input :first_name, :last_name, :email, :phone

    input = params.permit(:first_name, :last_name, :email, :phone, :promoter_id)

    @customer = Customer.create!(input)

    render 'show'
  end

  def update
    customer

    render 'show'
  end

  protected

  def promoter
    @promoter ||= params[:promoter_slug] ? User.find_by_url_slug(params[:promoter_slug]) : nil
  end

  def promoter?
    !!promoter
  end

  def customer
    @customer ||= params[:quote_slug] ? Customer.find_by_url_slug(params[:quote_slug]) : nil
  end

  def customer?
    !!customer
  end
  
end