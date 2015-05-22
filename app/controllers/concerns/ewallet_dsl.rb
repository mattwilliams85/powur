module EwalletDSL
  extend ActiveSupport::Concern
  require 'ipayout'
  include EwalletRequestHelper
  attr_accessor :client

  def ewallet_request(service_name, query)
    client = Ipayout.new
    service = client.get_service(service_name)
    populated_params = assign_param_values(query['options_hash'], service.parameters)

    response = client.ewallet_request(populated_params)
    response
  end

  private

  # returns a hash consisting of the available service
  # paramaters populated with any matching parameter value from the form.
  def assign_param_values(input_params, api_params)
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
    build_load_query(pay_period, bonus_amount_totals)
  end

  def prepare_register_request(user)
    build_registration_query(user)
  end

  def register_new_ipayout_user(user)
    request_params = prepare_register_request(user)
    result = ewallet_request(:register_user, request_params)

    if result[:m_Text] == 'OK'
      result[:status] = 'success'
    else
      message = 'Unsuccessful Registration Request'
      result = { status: 'error', message: message, result_data: result }
    end
    result
  end

  def get_ewallet_account_status(user)
    request_params = build_account_query(user)
    result = ewallet_request(:get_user_account_status, request_params)

    if result[:m_Text] == 'OK'
      result[:status] = 'success'
    else
      message = 'Unsuccessful Account Status Request for user ' + user.email
      result = { status: 'error', message: message }
    end
    result
  end

  def request_user_auto_login(user)
    request_params = build_auto_login_query(user)
    result = ewallet_request(:request_user_auto_login, request_params)

    if result[:m_Text] == 'OK'
      result[:status] = 'success'
    else
      message = 'Unsuccessful Auto Login Request for user ' + user.email
      result = { status: 'error', message: message }
    end
    result
  end

  def build_auto_login_url(user)
    result = request_user_auto_login(user)
    ref = ''
    if result[:ProcessorTransactionRefNumber]
      ref = result[:ProcessorTransactionRefNumber]
    end
    ENV['IPAYOUT_AUTO_LOGIN_ENDPOINT'] + ref
  end

  def get_ewallet_customer_details(user)
    request_params = build_details_query(user)
    result = ewallet_request(:get_customer_details, request_params)
    if result[:m_Text] == 'OK'
      result[:status] = 'success'
    else
      message = 'Unsuccessful Details Request for user ' + user.email
      result = { status: 'error', message: message }
    end
    result
  end
end
