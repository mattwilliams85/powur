class CustomersController < AuthController

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
    @customer = current_user.customers.find_by(id: params[:id])

    @customer.update_attributes!(input)

    show
  end

  private

  def input
    params.permit(:email, :first_name, :last_name, :address, :phone, :kwh)
  end

end
