module Anon
  class ProductInvitesController < AnonController
    before_action :fetch_customer, only: [ :show, :update ]

    def update
      @customer.update_attributes!(customer_input)
      @lead = Lead.create!(
        product_id: product.id,
        customer:   @customer,
        user_id:    @customer.user_id,
        data:       lead_input)

      if @lead.ready_to_submit?
        @lead.submit!
        @lead.email_customer if @lead.can_email?
      end

      render 'auth/leads/show'
    end

    private

    def fetch_customer
      @customer = Customer.find_by(code: params[:id])
      not_found!(:product_invite) unless @customer
    end

    def customer_input
      allow_input(:first_name, :last_name, :email,
                  :phone, :address, :city, :state, :zip)
    end

    def product
      @product ||= Product.default
    end

    def lead_input
      allow_input(*product.quote_fields.map(&:name))
    end
  end
end
