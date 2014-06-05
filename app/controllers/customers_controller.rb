class CustomersController < AuthController

  before_filter :fetch_customer, only: [ :show, :update ]

  def index
    @customers = current_user.customers.order(created_at: :desc)
  end

  def show
    render 'show'
  end

  def create
    @customer = current_user.create_customer(input)

    show
  end

  def update
    @customer.update_attributes!(input)

    show
  end

  private

  def input
    params.permit(:email, :first_name, :last_name, :address, :city, :state, :zip, :phone, :kwh)
  end

  def fetch_customer
    @customer = current_user.customers.find_by(id: params[:id]) or 
      not_found!(:customer)
  end

end
