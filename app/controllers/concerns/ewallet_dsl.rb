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
    populated_params = assign_param_values(query['options_hash'], service.parameters)
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
    param_hash
  end

  def prepare_load_request(pay_period, bonus_amount_totals)
    construct_ewallet_load_query(pay_period, bonus_amount_totals)
  end

  def prepare_register_request(user)
    construct_ewallet_registration_query(user)
  end

  def register_new_ipayout_user(user)
    request_params = prepare_register_request(user)
    result = ewallet_request("register_user", request_params)

    if result[:m_Text] == 'OK'
      result[:status] = "success"
    else
      message = "Unsuccessful Registration Request"
      result = {status: "error", message: message}
    end
    result
  end

  def get_ewallet_account_status(user)
    request_params = construct_ewallet_account_status_query(user)
    result = ewallet_request("get_user_account_status", request_params)

    if result[:m_Text] == 'OK'
      result[:status] = "success"
    else
      message = "Unsuccessful Account Status Request for user " + user.email
      result = {status: "error", message: message}
    end
    result
  end

  def get_ewallet_customer_details(user)
    request_params = construct_ewallet_customer_details_query(user)
    result = ewallet_request("get_customer_details", request_params)
    if result[:m_Text] == 'OK'
      result[:status] = "success"
    else
      message = "Unsuccessful Details Request for user " + user.email
      result = {status: "error", message: message}
    end
    result
  end

end
