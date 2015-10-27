module Anon
  class CustomersController < AnonController
    before_action :fetch_customer, only: [ :show, :update ]

    def update
      require_input :first_name, :last_name, :email,
                    :phone, :address, :city, :state, :zip

      @customer.update_attributes!(customer_input)

      @lead = find_or_create_lead
      if @lead.ready_to_submit?
        @lead.submit!
        @lead.email_customer if @lead.can_email?
        @customer.accepted!
      end

      render 'show'
    end

    private

    def fetch_customer
      @customer = Customer.find_by(code: params[:id])
      not_found!(:customer) if @customer.nil? || @customer.lead_submitted?
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

    def find_or_create_lead
      product.quote_fields.each { |field| require_input field.name }

      attrs = { product_id: product.id, customer_id: @customer.id }
      Lead.find_or_create_by(attrs) do |lead|
        lead.user_id = @customer.user_id
        lead.data = lead_input
      end
    end
  end
end