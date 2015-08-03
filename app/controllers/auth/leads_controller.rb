module Auth
  class LeadsController < AuthController
    before_action :fetch_user!
    before_action :fetch_leads, only: [ :index ]
    before_action :fetch_lead,
                  only: [ :show, :update, :destroy, :resend, :submit ]

    page max_limit: 500
    sort created:  { created_at: :desc },
         customer: 'customers.last_name asc, customers.first_name asc'
    filter :submitted_status,
           options:  [ :submitted, :not_submitted ],
           required: false
    filter :data_status,
           options:  Lead.data_statuses.keys,
           required: false
    filter :sales_status,
           options:  Lead.sales_statuses.keys,
           required: false

    def index
      @leads = apply_list_query_options(@leads)

      render 'index'
    end

    def show
      render 'show'
    end

    def create
      customer = Customer.create!(customer_input)
      @lead = Lead.create!(
        product_id: product.id,
        customer:   customer,
        user:       current_user,
        data:       lead_input)

      show
    end

    def update
      @lead.customer.update_attributes!(customer_input)
      @lead.update(data: lead_input)

      show
    end

    def destroy
      error!(:delete_lead) if @lead.submitted_at?

      @lead.destroy

      head :no_content
    end

    def resend
      @lead.email_customer if @lead.can_email?

      show
    end

    def submit
      error!(:cannot_submit_lead) unless @lead.ready_to_submit?

      @lead.submit!
      @lead.email_customer if @lead.can_email?

      show
    end

    private

    def fetch_leads
      scope = Lead
        .includes(:customer, :user, :product)
        .references(:customer, :user, :product)
      scope = scope.where(user_id: @user.id) if @user
      scope = scope.merge(Customer.search(params[:search])) if params[:search]
      @leads = scope
    end

    def fetch_lead
      id = params[:id].to_i
      @lead =
        if admin?
          Lead.find_by(id: id)
        else
          Lead.find_for_downline(id, current_user.id)
        end
      not_found!(:lead) unless @lead
    end

    def customer_input
      allow_input(:first_name, :last_name, :email,
                  :phone, :address, :city, :state, :zip, :notes)
    end

    def product
      @product ||= Product.default
    end

    def lead_input
      allow_input(*product.quote_fields.map(&:name))
    end
  end
end
