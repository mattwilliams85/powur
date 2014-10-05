require 'faraday'
require 'eyecue_ipayout/error/bad_request'
require 'eyecue_ipayout/error/too_many_requests'
require 'eyecue_ipayout/error/forbidden'
require 'eyecue_ipayout/error/not_acceptable'
require 'eyecue_ipayout/error/not_found'
require 'eyecue_ipayout/error/unauthorized'

module EyecueIpayout
  module Response
    class RaiseClientError < Faraday::Response::Middleware
      def on_complete(env)
        case env[:status].to_i
        when 400
          raise EyecueIpayout::Error::BadRequest.new(error_message(env), env[:response_headers])
        when 401
          raise EyecueIpayout::Error::Unauthorized.new(error_message(env), env[:response_headers])
        when 403
          if env[:body]['error'] == 'over_limit'
            raise EyecueIpayout::Error::TooManyRequests.new(error_message(env), env[:response_headers])
          else
            raise EyecueIpayout::Error::Forbidden.new(error_message(env), env[:response_headers])
          end
        when 404
          raise EyecueIpayout::Error::NotFound.new(error_message(env), env[:response_headers])
        when 406
          raise EyecueIpayout::Error::NotAcceptable.new(error_message(env), env[:response_headers])
        end
      end

      private

      def error_message(env)
        "#{env[:method].to_s.upcase} #{env[:url].to_s}: #{env[:status]}#{error_body(env[:body])}"
      end

      def error_body(body)
        if body.nil?
          nil
        elsif body['error']
          ": #{body['error']}"
        elsif body['errors']
          first = Array(body['errors']).first
          if first.kind_of? Hash
            ": #{first['message'].chomp}"
          else
            ": #{first.chomp}"
          end
        end
      end
    end
  end
end

