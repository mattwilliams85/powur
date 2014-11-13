module EwalletDSL
  extend ActiveSupport::Concern
  require 'eyecue_ipayout'
  include EwalletRequestHelper
  attr_accessor :client

  # def initialize

  # end

  def ewallet_request(service_name, query)
    client = EyecueIpayout.new
    puts 'eWallet_request:: call:' + service_name



    service = client.get_service(service_name)


    puts "CHECK service.parameters"
    puts "CHECK query['parameters']"
    populated_params = assign_param_values(query['options_hash'], service.parameters)
    pp populated_params


    response = client.ewallet_request(populated_params)

    # response = client.ewallet_request(query)

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
        param_hash[api_param_name] = input_params[api_param_name]
      end
    end
    # check param_hash

    param_hash
  end

  def prepare_load_request(pay_period, bonus_amount_totals)
    puts 'PREPARE LOAD REQUEST'
    construct_ewallet_load_query(pay_period, bonus_amount_totals)
  end

  def prepare_register_request(user)
    puts 'PREPARE REGISTER REQUEST'
    construct_ewallet_registration_query(user)
  end

end
