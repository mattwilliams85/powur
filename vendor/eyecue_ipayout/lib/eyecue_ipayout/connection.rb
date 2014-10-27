require 'faraday'
require 'faraday_middleware'
require 'eyecue_ipayout/core_ext/hash'
require 'eyecue_ipayout/response/raise_client_error'
require 'eyecue_ipayout/response/raise_server_error'
require 'eyecue_ipayout/config'

module EyecueIpayout
  module Connection
    private

    # Returns a Faraday::Connection object
    #
    # @param options [Hash] A hash of options
    # @return [Faraday::Connection]
    def connection()
      puts '!!!!!!EyecueIpayout::Connection ->Connection'
      default_options = {
        headers: {
          accept: 'application/json',
          user_agent: user_agent
        },
        ssl: { verify: false },

      }


      faraday_options = connection_options.deep_merge(default_options)
      faraday_options['url'] = ENV['IPAYOUT_API_ENDPOINT']
      puts '!!!!!!EyecueIpayout::Connection->Connection...inst connection'
      # @connection = Faraday.new(faraday_options['url']) do |faraday|

      #   faraday.request :url_encoded
      #   faraday.response :logger
      #   faraday.adapter Faraday.default_adapter
      # faraday.use EyecueIpayout::Response::RaiseClientError
      # faraday.use EyecueIpayout::Response::RaiseServerError
      # faraday.use Faraday::Response::Mashify
      # faraday.use Faraday::Response::ParseJson
      # end

      Faraday.new(:url => faraday_options['url']) do |faraday|
        faraday.request :url_encoded
        faraday.response :logger
        faraday.adapter Faraday.default_adapter
        faraday.use EyecueIpayout::Response::RaiseClientError
        faraday.use EyecueIpayout::Response::RaiseServerError
        faraday.use Faraday::Response::Mashify
        faraday.use Faraday::Response::ParseJson
      end

      # @connection
    end
  end
end