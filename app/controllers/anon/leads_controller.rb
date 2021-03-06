module Anon
  class LeadsController < AnonController
    before_action :fetch_user, only: [ :create ]
    before_action :fetch_lead, only: [ :show, :update ]

    def show
      @lead.touch(:last_viewed_at)
      render :show
    end

    def create
      require_input :first_name, :last_name, :email,
                    :phone, :address, :city, :state, :zip

      @lead = Lead.create!(
        lead_input.merge(
          product_id: product.id,
          user:       @user,
          data:       lead_data_input))

      submit_to_sc

      show
    end

    def update
      require_input :first_name, :last_name, :email,
                    :phone, :address, :city, :state, :zip

      @lead.update_attributes!(lead_input.merge(data: lead_data_input))

      submit_to_sc

      show
    end

    private

    def fetch_user
      @user = User.find_by(id: params[:user_id].to_i)
      not_found!(:user) unless @user
    end

    def fetch_lead
      @lead = Lead.find_by(code: params[:id])
      not_found!(:invite) if @lead.nil? || @lead.submitted?
    end

    def lead_input
      allow_input(:first_name, :last_name, :email,
                  :phone, :address, :city, :state, :zip, :call_consented)
    end

    def lead_data_input
      allow_input(*product.quote_fields.map(&:name))
    end

    def product
      @product ||= Product.default
    end

    def submit_to_sc
      error!(:invalid_zip, :zip) unless Lead.valid_zip?(lead_input['zip'])
      error!(:unqualified_zip, :zip) if @lead.ineligible_location?
      error!(:cannot_submit_lead) unless @lead.ready_to_submit?
      @lead.submit!
      @lead.email_customer if @lead.can_email?
      @lead.accepted!
      Lead.where.not(id: @lead.id)
        .where(email: @lead.email)
        .where.not(invite_status: Lead.invite_statuses[:accepted])
        .delete_all
    rescue IntegrationError => e
      Airbrake.notify(e, error: e.error.inspect, lead_id: @lead.id)
      error!(:solarcity_api)
    end
  end
end
