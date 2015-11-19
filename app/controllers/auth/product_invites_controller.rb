module Auth
  class ProductInvitesController < AuthController
    before_action :validate_existence, only: [ :create ]
    before_action :fetch_customer, only: [
      :show, :update, :destroy, :resend, :email ]

    page max_limit: 20
    sort created:  { created_at: :desc },
         customer: 'customers.last_name asc, customers.first_name asc'
    filter :status,
           options:  Customer.statuses.keys,
           required: false

    def index
      invites_scope = current_user.customers.where.not(
        status: Customer.statuses[:accepted])
      @invites = apply_list_query_options(invites_scope)

      render 'index'
    end

    def show
      render 'show'
    end

    def create
      require_input :first_name, :last_name, :email

      @customer = Customer.create!(
        customer_input.merge(user_id: current_user.id))
      if @customer.email?
        PromoterMailer.product_invitation(@customer).deliver_later
      end
      @customer.delay.send_sms

      show
    end

    def update
      @customer.update_attributes!(customer_input)

      index
    end

    def resend
      PromoterMailer.product_invitation(@customer).deliver_later
      @customer.touch

      index
    end

    def destroy
      @customer.destroy!

      index
    end

    private

    def customer_input
      allow_input(:first_name, :last_name, :email,
                  :phone, :address, :city, :state, :zip, :notes)
    end

    def validate_existence
      if !params[:email].present? || params[:confirm_existing_email].to_i == 1
        return
      end
      customer = Customer.find_by(email: customer_input['email'])
      warn!(:invite_exists, :email,
            sponsor: customer.user.full_name, email: customer.email) if customer
    end

    def fetch_customer
      @customer = Customer.find(params[:id])
    end
  end
end
