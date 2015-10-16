module Auth
  class ProductInvitesController < AuthController
    before_action :validate_existence, only: [ :create ]
    before_action :fetch_invite, only: [ :show ]

    page
    sort created:  { created_at: :desc },
         customer: 'customers.last_name asc, customers.first_name asc'
    filter :status,
           options:  Customer.statuses.keys,
           required: false

    def index
      @invites = apply_list_query_options(current_user.customers)

      render 'index'
    end

    def show
      render 'show'
    end

    def create
      @customer = Customer.create!(
        customer_input.merge(user_id: current_user.id))
      PromoterMailer.product_invitation(@customer).deliver_later

      show
    end

    private

    def customer_input
      require_input :email
      params[:email].downcase! unless SystemSettings.case_sensitive_auth

      allow_input(:first_name, :last_name, :email,
                  :phone, :address, :city, :state, :zip, :notes)
    end

    def validate_existence
      customer = Customer.find_by(email: customer_input['email'])
      error!(:product_invite_exist, :email) if customer
    end

    def fetch_customer
      @customer = Customer.find(params[:id])
    end
  end
end
