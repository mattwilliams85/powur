module Anon
  class ZipValidatorsController < AnonController
    def validate
      sc_api_response = Timeout::timeout(3) do
        Net::HTTP.get('api.solarcity.com', '/solarbid/api/warehouses/zip/' + params[:zip])
      end

      render json: { zip: params[:zip], valid: !!JSON.parse(sc_api_response)['IsInTerritory'] }

    rescue => e
      Airbrake.notify(e)
      render json: { zip: params[:zip], valid: true }
    end
  end
end