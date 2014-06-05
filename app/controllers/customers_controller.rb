class CustomersController < AuthController

  before_filter :fetch_customer, only: [ :show, :update, :destroy ]

  def index
    @customers = current_user.customers.order(created_at: :desc)

    render 'index'
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

    confirm :update, entity: @customer.full_name

    show
  end

  def destroy
    @customer.destroy

    confirm :delete, entity: @customer.full_name

    index
  end

  private

  def input
    params.permit(:first_name, :last_name, :email, :phone, :address, :city, 
      :state, :zip, :utility, :rate_schedule, :kwh, :roof_material, :roof_age)
  end

  def fetch_customer
    @customer = current_user.customers.find_by(id: params[:id]) or 
      not_found!(:customer)
  end

end
