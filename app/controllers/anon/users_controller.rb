module Anon
  class UsersController < AnonController
    before_action :fetch_lead, only: [ :show, :update ]

    def show
      @lead.touch(:last_viewed_at)
    end

    def update
      require_input :first_name, :last_name, :email,
                    :phone, :address, :city, :state, :zip

      @lead.update_attributes!(lead_input.merge(data: lead_data_input))

      if @lead.ready_to_submit?
        @lead.submit!
        @lead.email_customer if @lead.can_email?
        @customer.accepted!
        Lead.where.not(id: @lead.id)
          .where(email: @lead.email)
          .where.not(status: Lead.statuses[:accepted])
          .delete_all
      end

      render 'show'
    end

    private

    def fetch_lead
      @lead = Lead.find_by(user_id: params[:id])
      not_found!(:user) if @lead.nil? || @lead.submitted?
    end

    def lead_input
      allow_input(:first_name, :last_name, :email,
                  :phone, :address, :city, :state, :zip)
    end

    def lead_data_input
      allow_input(*product.quote_fields.map(&:name))
    end

    def product
      @product ||= Product.default
    end
  end
end
