require 'eyecue_ipayout/version'
require 'eyecue_ipayout/service'
require 'eyecue_ipayout/service_param'

module EyecueIpayout
  class ServiceParamMap
    attr_accessor :ewallet_services
    # Initializes new ServiceParamMap object
    #
    # @param [String] name
    # @param [Hash] expected_type
    # @param [Boolean] required
    # @return [EyecueIpayout::ServiceParam]
    # @instantiate EyecueIpayout::ServiceParam.new("FirstName", "String", true)

    def initialize
      puts '!!!!!!!!!INITIALIZE SERVICE PARAM MAP'
      @ewallet_services = {}
      build_service_map
    end

    def get_service_by_name(service_name)
      @ewallet_services[service_name] if @ewallet_services.key? service_name
    end

    def build_service_map
      #  eWallet_RegisterUser Service Map
      register_user_service = EyecueIpayout::Service.new('register_user')
      register_user_service.add_param('fn', 'String', true)
      register_user_service.add_param('endpoint', 'String', true)
      register_user_service.add_param('MerchantGUID', 'String', true)
      register_user_service.add_param('MerchantPassword', 'String', true)
      register_user_service.add_param('UserName', 'String', true)
      register_user_service.add_param('FirstName', 'String', true)
      register_user_service.add_param('FirstName', 'String', true)
      register_user_service.add_param('LastName', 'String', true)
      register_user_service.add_param('CompanyName', 'String', true)
      register_user_service.add_param('Address1', 'String', true)
      register_user_service.add_param('Address2', 'String', true)
      register_user_service.add_param('City', 'String', true)
      register_user_service.add_param('State', 'String', true)
      register_user_service.add_param('ZipCode', 'String', true)
      register_user_service.add_param('Country2xFormat', 'String', true)
      register_user_service.add_param('PhoneNumber', 'String', true)
      register_user_service.add_param('CellPhoneNumber', 'String', false)
      register_user_service.add_param('EmailAddress', 'String', true)
      register_user_service.add_param('SSN', 'String', false)
      register_user_service.add_param('CompanyTaxID', 'String', false)
      register_user_service.add_param('GovernmentID', 'String', false)
      register_user_service.add_param('MilitaryID', 'String', false)
      register_user_service.add_param('PassportNumber', 'String', false)
      register_user_service.add_param('DriversLicense', 'String', false)
      register_user_service.add_param('DateOfBirth', 'String', true)
      register_user_service.add_param('WebsitePassword', 'String', true)
      register_user_service.add_param('DefaultCurrency', 'String', true)
      register_user_service.add_param('SkipAutoSVCOrder', 'String', false)
      register_user_service.add_param('PreferredLanguage', 'String', false)
      register_user_service.add_param('IsBusinessUser', 'String', false)
      register_user_service.add_param('BusinessUserName', 'String', false)

      register_user_service.response_parameters = ['m_Code', 'm_Text', 'LogTransactionID',
                                                   'TransactionRefID', 'ACHTransactionID',
                                                   'ProcessorTransactionRefNumber',
                                                   'CustomerFeeAmount', 'CurrencyCode']

      #  eWallet_GetCustomerDetails Service Map
      get_customer_details_service = EyecueIpayout::Service.new('get_customer_details')
      get_customer_details_service.add_param('fn', 'String', true)
      get_customer_details_service.add_param('endpoint', 'String', true)
      get_customer_details_service.add_param('MerchantGUID', 'String', true)
      get_customer_details_service.add_param('MerchantPassword', 'String', true)
      get_customer_details_service.add_param('UserName', 'String', true)

      res_params = ['UserName', 'CustomerGuid', 'IsActivated', 'Email',
                    'FirstName', 'LastName', 'CompanyName', 'Phone',
                    'CellPhoneNumber', 'eWalletID', 'Address1', 'Address2',
                    'State', 'City', 'ZipCode', 'Country', 'DateOfBirth',
                    'IsSuspended', 'IsInfoVerified', 'IsClosed', 'CreatedDate',
                    'IsAgreedToFees', 'IsBusiness', 'IsInvalidEmail',
                    'PreferredLanguage', 'SVCShippingAddress']
      get_customer_details_service.response_parameters = res_params

      #  eWallet_GetUserAccountStatus Service
      get_user_account_status_service = EyecueIpayout::Service.new('get_user_account_status')
      get_user_account_status_service.add_param('fn', 'String', true)
      get_user_account_status_service.add_param('endpoint', 'String', true)
      get_user_account_status_service.add_param('MerchantGUID', 'String', true)
      get_user_account_status_service.add_param('MerchantPassword',
                                                'String', true)
      get_user_account_status_service.add_param('UserName', 'String', true)

      #  eWallet_G_serviceetUserAccountStatus Service
      ewallet_load_service = EyecueIpayout::Service.new('ewallet_load')
      ewallet_load_service.add_param('fn', 'String', true)
      ewallet_load_service.add_param('endpoint', 'String', true)
      ewallet_load_service.add_param('MerchantGUID', 'String', true)
      ewallet_load_service.add_param('MerchantPassword', 'String', true)
      ewallet_load_service.add_param('PartnerBatchID', 'String', true)
      ewallet_load_service.add_param('PoolID', 'String', true)
      ewallet_load_service.add_param('MerchantPassword', 'String', true)
      ewallet_load_service.add_param('arrAccounts', 'String', true)
      ewallet_load_service.add_param('AllowDuplicates', 'String', true)
      ewallet_load_service.add_param('AutoLoad', 'Boolean', true)
      ewallet_load_service.add_param('CurrencyCode', 'Boolean', true)
      ewallet_load_service.response_parameters = ['m_Code', 'm_Text']

      @ewallet_services['register_user'] = register_user_service
      @ewallet_services['get_customer_details'] = get_customer_details_service
      @ewallet_services['get_user_account_status'] = get_user_account_status_service
      @ewallet_services['ewallet_load'] = ewallet_load_service
    end
  end
end
