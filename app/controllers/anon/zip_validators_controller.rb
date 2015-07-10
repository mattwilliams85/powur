module Anon
  class ZipValidatorsController < AnonController
    def validate
      sc_api_response = Timeout::timeout(3) do
        Net::HTTP.get('api.solarcity.com', '/solarbid/api/warehouses/zip/' + params[:zip])
      end

      render json: { zip: params[:zip], valid: !!JSON.parse(sc_api_response)['IsInTerritory'] }

    rescue => e
      Airbrake.notify(e)
      return true   # Fallback to true and notify with Airbrake
    end
  end
end