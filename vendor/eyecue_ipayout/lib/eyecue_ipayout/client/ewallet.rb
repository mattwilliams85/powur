module EyecueIpayout
  class Client
    
    module Ewallet
      require 'json'

      def register_user(params={}, options={})          
          response = connection.post do |req|
            req.url ''
            req.headers['Content-Type'] = 'application/json'
            req.body = params.to_json
          end

          puts response.body.response
      end

      def get_customer_details(params={}, options={})          
          response = connection.post do |req|
            req.url ''
            req.headers['Content-Type'] = 'application/json'
            req.body = params.to_json
          end
          response.body.response
      end

    end
  end
end



