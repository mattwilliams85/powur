module EwalletDSL
  extend ActiveSupport::Concern
  require 'eyecue_ipayout'
  attr_accessor :client

  def ewallet_request(service_name, params)
    client = EyecueIpayout.new
    puts 'eWallet_request:: call:' + service_name
    service = client.get_service(service_name)
    options_hash   = assign_param_values(params, service.parameters)
    response = client.ewallet_request(options_hash)
    puts "!!!!!!!RESPONSE FROM ewallet_request: "
    response
  end

  private

  # returns a hash consisting of the available service
  # paramaters populated with any matching parameter value from the form.
  def assign_param_values(input_params, api_params)
    # loop through params and assign values
    param_hash = {}
    api_params.each do |api_param_name, api_param_obj|
      api_param_name = api_param_obj.name
      if input_params.key? api_param_name
        #puts 'SET KEY: ' + api_param_name + '=' + input_params[api_param_name]
        param_hash[api_param_name] = input_params[api_param_name]
      end
    end
    # check param_hash
    #byebug
    param_hash
  end
end
