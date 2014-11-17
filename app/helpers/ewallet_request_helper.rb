module EwalletRequestHelper
    def construct_ewallet_load_query(pay_period, bonus_payments)
    service_hash = {}
    service_hash['api_method'] = "ewallet_load"

    options_hash = {}
    options_hash['MerchantGUID'] = ENV['IPAYOUT_MERCHANT_GUID']
    options_hash['MerchantPassword'] = ENV['IPAYOUT_MERCHANT_PASSWORD']
    options_hash['fn'] = 'eWallet_Load'
    options_hash['endpoint'] = ENV['IPAYOUT_API_ENDPOINT']
    options_hash['PartnerBatchID'] = pay_period.id.to_s
    options_hash['AllowDuplicates'] = 'true'
    options_hash['AutoLoad'] = 'false'
    options_hash['CurrencyCode'] = 'USD'

    payment_accounts = []
    bonus_payments.each do |payment|
      user_hash = {}
      user = User.find(payment[:user_id])
      if user.present?
        puts 'user found'
        user_hash['UserName'] = user[:email]
        user_hash['Amount'] = payment[:amount].to_s
        user_hash['MerchantReferenceID'] = pay_period.id.to_s + '-' + user[:id].to_s
        payment_accounts.push(user_hash)
      else
        #WHAT SHOULD WE DO HERE?
        puts 'User doesn\'t exist...Skipping'
      end
    end

    options_hash['arrAccounts'] = payment_accounts

    service_hash['options_hash'] = options_hash

    #ap service_hash
    service_hash
  end

  def construct_ewallet_account_status_query(user_params)
    service_hash = {}
    service_hash['api_method'] = "eWallet_GetUserAccountStatus"

    options_hash = {}
    options_hash['MerchantGUID'] = ENV['IPAYOUT_MERCHANT_GUID']
    options_hash['MerchantPassword'] = ENV['IPAYOUT_MERCHANT_PASSWORD']
    options_hash['fn'] = "eWallet_GetUserAccountStatus"
    options_hash['endpoint'] = ENV['IPAYOUT_API_ENDPOINT']
    options_hash['UserName'] = user_params[:email]

    service_hash['options_hash'] = options_hash
    service_hash
  end

  def construct_ewallet_customer_details_query(user_params)
    service_hash = {}
    service_hash['api_method'] = "eWallet_GetCustomerDetails"

    options_hash = {}
    options_hash['MerchantGUID'] = ENV['IPAYOUT_MERCHANT_GUID']
    options_hash['MerchantPassword'] = ENV['IPAYOUT_MERCHANT_PASSWORD']
    options_hash['fn'] = "eWallet_GetCustomerDetails"
    options_hash['endpoint'] = ENV['IPAYOUT_API_ENDPOINT']
    options_hash['UserName'] = user_params[:email]

    service_hash['options_hash'] = options_hash
    service_hash
  end

  def construct_ewallet_registration_query(user_params)
    service_hash = {}
    service_hash['api_method'] = "register_user"

    options_hash = {}
    options_hash['MerchantGUID'] = ENV['IPAYOUT_MERCHANT_GUID']
    options_hash['MerchantPassword'] = ENV['IPAYOUT_MERCHANT_PASSWORD']
    options_hash['fn'] = "eWallet_RegisterUser"
    options_hash['endpoint'] = ENV['IPAYOUT_API_ENDPOINT']
    options_hash['UserName'] = user_params[:email]
    options_hash['FirstName'] = user_params[:first_name]
    options_hash['LastName'] = user_params[:first_name]
    options_hash['CompanyName'] = ''
    options_hash['Address1'] = user_params[:address_1]
    options_hash['Address2'] = user_params[:address_2]
    options_hash['City'] = user_params[:city]
    options_hash['State'] = user_params[:state]
    options_hash['ZipCode'] = user_params[:zip]
    options_hash['Country2xFormat'] = 'US'
    options_hash['PhoneNumber'] = user_params[:phone]
    options_hash['CellPhoneNumber'] = ''
    options_hash['EmailAddress'] = user_params[:email]
    options_hash['SSN'] = ''
    options_hash['CompanyTaxID'] = ''
    options_hash['GovernmentID'] = ''
    options_hash['MilitaryID'] = ''
    options_hash['PassportNumber'] = ''
    options_hash['DriversLicense'] = ''
    options_hash['DateOfBirth'] = ''
    options_hash['WebsitePassword'] = ''
    options_hash['DefaultCurrency'] = ''
    options_hash['SkipAutoSVCOrder'] = ''
    options_hash['PreferredLanguage'] = ''
    options_hash['IsBusinessUser'] = ''
    options_hash['BusinessUserName'] =''

    service_hash['options_hash'] = options_hash

    #ap service_hash
    service_hash
  end
end
