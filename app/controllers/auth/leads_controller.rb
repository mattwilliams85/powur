module Auth
  class LeadsController < AuthController
    before_action :fetch_user!
    before_action :fetch_leads, only: [ :index, :team, :destroy, :resend ]
    before_action :fetch_lead,
                  only: [ :show, :update, :destroy, :resend, :submit, :invite ]

    page max_limit: 10
    sort created:  { created_at: :desc },
         customer: 'leads.last_name asc, leads.first_name asc'
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

      @lead = Lead.create!(
        lead_input.merge(
          product_id:     product.id,
          user:           current_user,
          call_consented: false,
          data:           lead_data_input))

      show
    end

    def update
      error!(:update_lead) if @lead.submitted_at?
      require_input :first_name, :last_name, :email, :phone

      @lead.update!(lead_input.merge(data: lead_data_input))

      show
    end

    def destroy
      error!(:delete_lead) if @lead.submitted_at?

      @lead.destroy

      head :ok
    end

    def resend
      @lead.email_customer if @lead.can_email?

      index
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

    def invite
      if @lead.not_sent?
        PromoterMailer.product_invitation(@lead).deliver_later if @lead.email?
        @lead.delay.send_sms_invite
        @lead.sent!
      end

      show
    end

    def summary
      metrics = @user.metrics
      data_scope =
        params[:personal].present? ? :leads_personal_count : :leads_count
      days = params[:days]

      @metrics_data = {
        leads:     metrics.send(data_scope, :submitted, days),
        proposals: metrics.send(data_scope, :converted, days),
        closed:    metrics.send(data_scope, :closed_won, days),
        contracts: metrics.send(data_scope, :contracted, days),
        installs:  metrics.send(data_scope, :installed, days)
      }
    end

    private

    def fetch_leads
      scope = Lead
        .includes(:user, :product)
        .references(:user, :product)
      scope = scope
        .where(user_id: @user.id) if @user && action_name != 'team'
      days = params[:days].to_i
      scope = scope.where('leads.created_at > ?',
                          days.days.ago) if days > 0
      scope = scope.merge(Lead.search(params[:search])) if params[:search]
      scope = scope.merge(Lead.user_search(params[:user_search])) if params[:user_search]
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

    def lead_input
      allow_input(:first_name, :last_name, :email,
                  :phone, :address, :city, :state, :zip,
                  :notes)
    end

    def product
      @product ||= Product.default
    end

    def lead_data_input
      allow_input(*product.quote_fields.map(&:name))
    end
  end
end
