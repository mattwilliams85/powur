module Anon
  class ProductInvitesController < AnonController
    before_action :fetch_customer, only: [ :show, :update ]

    def update
      require_input :first_name, :last_name, :email,
                    :phone, :address, :city, :state, :zip

      @customer.update_attributes!(customer_input)

      product.quote_fields.each do |field|
        require_input field.name
      end

      @lead = Lead.where(product_id:  product.id,
                         customer_id: @customer.id).first
      @lead ||= begin
        @lead = Lead.create!(
          product_id: product.id,
          customer:   @customer,
          user_id:    @customer.user_id,
          data:       lead_input)
      end

      if @lead.ready_to_submit?
        @lead.submit!
        @lead.email_customer if @lead.can_email?
        @customer.accepted!
      end

      render 'auth/leads/show'
    end

    private

    def fetch_customer
      @customer = Customer.find_by(code: params[:id])
      not_found!(:product_invite) if @customer.nil? || @customer.lead_submitted?
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
