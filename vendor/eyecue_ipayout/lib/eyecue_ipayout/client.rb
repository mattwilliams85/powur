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
    def eWallet_request(params={}, options={})
        response = connection.post do |req|
          req.url ''
          req.headers['Content-Type'] = 'application/json'
          req.body = params.to_json
        end
        response.body.response
    end
  end
end

