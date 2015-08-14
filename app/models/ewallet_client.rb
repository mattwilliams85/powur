class EwalletClient
  attr_reader :client, :client_service,
              :api_endpoint, :auto_login_endpoint,
              :merchant_guid, :merchant_password

  def initialize
    @api_endpoint = ENV['IPAYOUT_API_ENDPOINT']
    @merchant_guid = ENV['IPAYOUT_MERCHANT_GUID']
    @merchant_password = ENV['IPAYOUT_MERCHANT_PASSWORD']
    @auto_login_endpoint = ENV['IPAYOUT_AUTO_LOGIN_ENDPOINT']
    @client = Ipayout.new
  end

  def service(name)
    @client_service = client.get_service(name)
  end

  def request(name, query)
    params = assign_param_values(query, service(name).parameters)
    client.ewallet_request(params)
  end

  def fetch(username)
    request(
      :get_customer_details,
      fetch_query('eWallet_GetCustomerDetails', username))
  end

  def create(opts)
    request(:register_user, create_query(opts))
  end

  def login_url(username)
    request(
      :request_user_auto_login,
      fetch_query('eWallet_RequestUserAutoLogin', username))
  end

  def ewallet_load(opts)
    request(:ewallet_load, load_query(opts))
  end

  def ewallet_individual_load(opts)
    request(:ewallet_load, individual_load_query(opts))
  end

  private

  def assign_param_values(input_opts, valid_opts)
    valid_opt_names = valid_opts.map { |_k, v| v.name }
    input_opts.select { |k, _v| valid_opt_names.include?(k) }
  end

  def base_options_hash
    { 'MerchantGUID'     => merchant_guid,
      'MerchantPassword' => merchant_password,
      'endpoint'         => api_endpoint }
  end

  def fetch_query(service_name, username)
    base_options_hash.merge(
      'fn'       => service_name,
      'UserName' => username)
  end

  def create_query(opts)
    base_options_hash.merge(
      'fn'              => 'eWallet_RegisterUser',
      'UserName'        => opts[:email],
      'FirstName'       => opts[:first_name],
      'LastName'        => opts[:last_name],
      'EmailAddress'    => opts[:email],
      'Address1'        => opts[:address_1],
      'Address2'        => opts[:address_2],
      'City'            => opts[:city],
      'State'           => opts[:state],
      'ZipCode'         => opts[:zip],
      'Country2xFormat' => 'US',
      'PhoneNumber'     => opts[:phone],
      'SSN'             => '',
      'DriversLicense'  => '',
      # set unknown date to 1/1/1900, they will set it on first user login
      'DateOfBirth'     => '1/1/1900',
      'WebsitePassword' => nil)
  end

  # Example:
  # client.load_query(
  #   batch_id: 'powur:1',
  #   payments: [{
  #     ref_id: 12,
  #     username: 'user@example.com',
  #     amount: 34
  #   }]
  # )
  def load_query(opts)
    list = []
    opts[:payments].each do |data|
      list.push(
        'UserName'            => data[:username],
        'Amount'              => data[:amount],
        'MerchantReferenceID' => data[:ref_id]
      )
    end

    base_options_hash.merge(
      'fn'              => 'eWallet_Load',
      'PartnerBatchID'  => opts[:batch_id],
      'AllowDuplicates' => 'true',
      'AutoLoad'        => 'false',
      'CurrencyCode'    => 'USD',
      'arrAccounts'     => list)
  end

  # Example:
  # client.individual_load_query(
  #   batch_id: 'powur:1',
  #   payment: {
  #     ref_id: 12,
  #     username: 'user@example.com',
  #     amount: 34
  #   }
  # )
  def individual_load_query(opts)
    base_options_hash.merge(
      'fn'              => 'eWallet_Load',
      'PartnerBatchID'  => opts[:batch_id],
      'AllowDuplicates' => 'true',
      'AutoLoad'        => 'false',
      'CurrencyCode'    => 'USD',
      'arrAccounts'     => [{
        'UserName'            => opts[:payment][:username],
        'Amount'              => opts[:payment][:amount],
        'MerchantReferenceID' => opts[:payment][:ref_id]
      }])
  end
end
