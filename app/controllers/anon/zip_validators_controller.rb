module Anon
  class ZipValidatorsController < AnonController
    before_action :fetch_customer, only: [ :create ]

    def create
      require_input :zip

      if Lead.valid_zip?(params[:zip])
        @is_valid = true
      else
        status_value = Customer.statuses[:ineligible_location]
        @customer.update_attribute(:status, status_value)
        error!(:invalid_zip, :zip)
      end
    rescue RestClient::RequestTimeout => e
      Airbrake.notify(e)
      @is_valid = true
    end

    private

    def fetch_customer
      @customer = Customer.find_by(code: params[:code])
      not_found!(:product_invite) unless @customer
    end
  end
end
