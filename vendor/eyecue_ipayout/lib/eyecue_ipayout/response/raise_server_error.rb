require 'faraday'
require 'eyecue_ipayout/error/bad_gateway'
require 'eyecue_ipayout/error/internal_server_error'
require 'eyecue_ipayout/error/service_unavailable'

module EyecueIpayout
  module Response
    class RaiseServerError < Faraday::Response::Middleware
      def on_complete(env)
        case env[:status].to_i
        when 500
          raise EyecueIpayout::Error::InternalServerError.new(error_message(env, "Don't look at me.  The server had an error."), env[:response_headers])
        when 502
          raise EyecueIpayout::Error::BadGateway.new(error_message(env, "It looks like the eWallet API is down or being upgraded."), env[:response_headers])
        when 503
          raise EyecueIpayout::Error::ServiceUnavailable.new(error_message(env, "(__-){ The eWallet API is over capacity."), env[:response_headers])
        end
      end

      private

      def error_message(env, body=nil)
        "#{env[:method].to_s.upcase} #{env[:url].to_s}: #{[env[:status].to_s + ':', body].compact.join(' ')}"
      end
    end
  end
end
