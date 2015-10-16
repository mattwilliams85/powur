module Anon
  class ZipValidatorsController < AnonController
    before_action :fetch_customer, only: [ :create ]

    def create
      require_input :zip
      error!(:invalid_zip, :zip) unless Lead.valid_zip?(params[:zip])

      if Lead.eligible_zip?(params[:zip])
        @is_valid = true
        @customer.zip = params[:zip]
        @customer.status = :initiated
        @customer.save!
      else
        status = Customer.statuses[:ineligible_location]
        @customer.update_attributes(status: status, zip: nil)
        error!(:unqualified_zip, :zip)
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
