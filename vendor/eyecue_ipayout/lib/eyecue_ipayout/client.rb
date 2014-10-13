require 'cgi'
require 'eyecue_ipayout/api'

module EyecueIpayout
  # Wrapper for the EyecueIpayout REST API

  class Client < API
    # Since we are consistently going to do a POST
    # containing JSON data, We don't need to break
    # this call out in to seperate client calls.
    # For this API, we pass the function call along
    # with the rest of the parameters in the 'fn' param
    def ewallet_request(params = {})
      puts '!!!!!!EyecueIpayout::Client -> eWallet_Request'
      response = connection.post params[:endpoint] do |req|
        req.headers['Content-Type'] = 'application/json'
        req.body = params.to_json
      end
      puts "RESPONSE:"
      puts response.body.response
      response.body.response
    end

    def get_service(service_name)
      puts '!!!!!!EyecueIpayout::Client -> get_service: ' + service_name
      puts 'eyecue_ipayout :: get_service(service_name):' + service_name
      service_param_map.get_service_by_name(service_name)
    end
  end
end
