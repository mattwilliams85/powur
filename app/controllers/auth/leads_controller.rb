module Auth
  class LeadsController < AuthController
    before_action :fetch_user!
    before_action :fetch_leads, only: [ :index, :team ]
    before_action :fetch_lead,
                  only: [ :show, :update, :destroy, :resend, :submit ]

    page max_limit: 10
    sort created:  { created_at: :desc },
         customer: 'customers.last_name asc, customers.first_name asc'
    filter :submitted_status,
           options:  [ :not_submitted, :submitted ],
           required: false
    filter :data_status,
           options:  Lead.data_statuses.keys[0...3],
           required: false
    filter :sales_status,
           options:  Lead.sales_statuses.keys,
           required: false

    def index
      @leads = apply_list_query_options(@leads)

      render 'index'
    end

    def team
      @leads = apply_list_query_options(
        Lead.team_leads(user_id: current_user.id, query: @leads))

      render 'index'
    end

    def show
      render 'show'
    end

    def create
      require_input :first_name, :last_name, :email, :phone

      customer = Customer.create!(
        customer_input.merge(user_id: current_user.id))
      @lead = Lead.create!(
        product_id: product.id,
        customer:   customer,
        user:       current_user,
        data:       lead_input)

      show
    end

    def update
      error!(:update_lead) if @lead.submitted_at?

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
    rescue Lead::SolarCityApiError => e
      Airbrake.notify(e)
      error!(:solarcity_api)
    end

    private

    def fetch_leads
      scope = Lead
        .includes(:customer, :user, :product)
        .references(:customer, :user, :product)
        .joins(:customer)
      scope = scope.where(user_id: @user.id) if @user
      scope = scope.where(
        'leads.created_at > ?', params[:days].to_i.days.ago) if params[:days]
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

    # def find_or_create_customer
    #   customer = Customer.where(
    #     email:   customer_input['email'],
    #     user_id: current_user.id).first
    #   if customer && !customer.lead?
    #     customer.update_attributes!(customer_input)
    #     customer
    #   else
    #     Customer.create!(customer_input)
    #   end
    # end

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
