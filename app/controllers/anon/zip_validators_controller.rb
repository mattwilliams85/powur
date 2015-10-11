module Anon
  class ZipValidatorsController < AnonController
    def create
      sc_api_response = Timeout::timeout(3) do
        Net::HTTP.get('api.solarcity.com', '/solarbid/api/warehouses/zip/' + params[:zip])
      end

      @is_valid = !!JSON.parse(sc_api_response)['IsInTerritory']
      @customer = Customer.find_by(code: params[:code])
      # TODO: update customer if zip is invalid
    rescue => e
      Airbrake.notify(e)
    end
  end
end
