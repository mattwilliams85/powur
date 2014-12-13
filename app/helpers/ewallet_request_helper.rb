module EwalletRequestHelper
  def find_or_create_ipayout_account(user)
    acct_status = get_ewallet_account_status(user)
    if acct_status[:status] == 'error'
      register_new_ipayout_user(user)
    end
  end

  def initialize_base_options_hash
    options_hash = {}
    options_hash['MerchantGUID'] =
      Rails.application.secrets.ipayout_merchant_guid
    options_hash['MerchantPassword'] =
      Rails.application.secrets.ipayout_merchant_password
    options_hash['endpoint'] = Rails.application.secrets.ipayout_api_endpoint
    options_hash
  end

  # some of these services sent the exact same request
  # differing only in the name of the service
  def build_simple_user_query(service_name, user_params)
    service_hash = {}
    service_hash['api_method'] = service_name
    options_hash = initialize_base_options_hash
    options_hash['fn'] = service_name
    options_hash['UserName'] = user_params[:email]
    service_hash['options_hash'] = options_hash
    service_hash
  end

  def build_load_query(pay_period, bonus_payments)
    service_hash = {}
    service_hash['api_method'] = :ewallet_load
    options_hash = initialize_base_options_hash
    options_hash['fn'] = 'eWallet_Load'
    options_hash['PartnerBatchID'] = pay_period.id.to_s
    options_hash['AllowDuplicates'] = 'true'
    options_hash['AutoLoad'] = 'false'
    options_hash['CurrencyCode'] = 'USD'

    payment_accounts = []
    failed_disbursements = []
    bonus_payments.each do |payment|
      user_hash = {}
      user = User.find(payment[:user_id])

      if user.present?
        # this is only for all those seed users in the
        # system. When this isn't running off of seed
        # data, they'll all have ipayout accounts from
        # the registration workflow.
        find_or_create_ipayout_account(user)
        user_hash['UserName'] = user[:email]
        user_hash['Amount'] = payment[:amount].to_s

        ref_id = pay_period.id.to_s + '-' + user[:id].to_s
        user_hash['MerchantReferenceID'] = ref_id

        payment_accounts.push(user_hash)
      else
        # Storing these just until I figure out what
        # we outght to do about
        failed_disbursements.push(user)
      end

    end
    # arrAccounts is an array of simple hash structures that
    # represent the user and the amount to pay.
    # Packing them all in like this allows
    # the eWallet_Load service to disburse funds to
    # many users in only one service call.
    options_hash['arrAccounts'] = payment_accounts
    service_hash['options_hash'] = options_hash

    service_hash
  end

  def build_account_query(user_params)
    build_simple_user_query('eWallet_GetUserAccountStatus', user_params)
  end

  def build_auto_login_query(user_params)
    build_simple_user_query('eWallet_RequestUserAutoLogin', user_params)
  end

  def build_details_query(user_params)
    build_simple_user_query('eWallet_GetCustomerDetails', user_params)
  end

  def build_registration_query(user_params)
    service_hash = {}
    service_hash['api_method'] = :register_user
    options_hash = initialize_base_options_hash
    options_hash['fn'] = 'eWallet_RegisterUser'
    options_hash['UserName'] = user_params[:email]
    options_hash['FirstName'] = user_params[:first_name]
    options_hash['LastName'] = user_params[:last_name]
    options_hash['EmailAddress'] = user_params[:email]
    options_hash['Address1'] = user_params[:address_1]
    options_hash['Address2'] = user_params[:address_2]
    options_hash['City'] = user_params[:city]
    options_hash['State'] = user_params[:state]
    options_hash['ZipCode'] = user_params[:zip]
    options_hash['Country2xFormat'] = 'US'
    options_hash['PhoneNumber'] = user_params[:phone]
    options_hash['SSN'] = ''
    options_hash['DriversLicense'] = ''
    # If date of birth is not known, set it to: 1/1/1900.
    # It will be asked on a first user login.
    options_hash['DateOfBirth'] = '1/1/1900'
    options_hash['WebsitePassword'] = user_params[:password]

    service_hash['options_hash'] = options_hash
    service_hash
  end
end
