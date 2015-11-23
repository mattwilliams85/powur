module Gibbon
  class APIRequest
    def rest_client
      options = {
        url:   api_url,
        proxy: ENV['QUOTAGUARDSTATIC_URL']
      }
      client = Faraday.new(options) do |faraday|
        faraday.response :raise_error
        faraday.adapter Faraday.default_adapter
      end
      client.basic_auth('apikey', self.api_key)
      client
    end
  end
end
