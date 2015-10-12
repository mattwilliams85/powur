module Anon
  class ZipValidatorsController < AnonController
    def create
      response = Timeout::timeout(3) do
        Net::HTTP.get('api.solarcity.com', '/solarbid/api/warehouses/zip/' + params[:zip])
      end

      @is_valid = !!JSON.parse(response)['IsInTerritory']
      @customer = Customer.find_by(code: params[:code])

      return if @is_valid || !@customer

      @customer.update_attribute(
        :status,
        Customer.statuses[:ineligible_location])

    rescue Timeout::Error => e
      Airbrake.notify(e)
      # default to true
      @is_valid = true
    end
  end
end
