module Anon
  class ZipValidatorsController < AnonController
    before_action :fetch_customer, only: [ :create ]

    def create
      @is_valid = Lead.valid_zip?(params[:zip])

      unless @is_valid
        @customer.update_attribute(
          :status,
          Customer.statuses[:ineligible_location])
      end

    rescue RestClient::RequestTimeout => e
      Airbrake.notify(e)
      # default to true
      @is_valid = true
    end

    private

    def fetch_customer
      @customer = Customer.find_by(code: params[:code])
      not_found!(:product_invite) unless @customer
    end
  end
end
