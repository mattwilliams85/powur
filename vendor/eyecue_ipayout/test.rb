require 'byebug'
require 'eyecue_ipayout'
require 'json'
require 'date'
# require 'eyecue_ipayout/service'
# require 'eyecue_ipayout/service_params'

IPAYOUT_API_ENDPOINT = 'https://testewallet.com/eWalletWS/ws_JsonAdapter.aspx'
IPAYOUT_MERCHANT_GUID = 'a4739056-7db6-40f3-9618-f2bcccbf70cc'
IPAYOUT_MERCHANT_PASSWORD = '9xXLvA66hi'

ENV['IPAYOUT_API_ENDPOINT'] = IPAYOUT_API_ENDPOINT
ENV['IPAYOUT_MERCHANT_GUID'] = IPAYOUT_MERCHANT_GUID
ENV['IPAYOUT_MERCHANT_PASSWORD'] = IPAYOUT_MERCHANT_PASSWORD

ipayout_client_options = {:IPAYOUT_API_ENDPOINT => IPAYOUT_API_ENDPOINT,
                          :IPAYOUT_MERCHANT_GUID => IPAYOUT_MERCHANT_GUID,
                          :IPAYOUT_MERCHANT_PASSWORD=>IPAYOUT_MERCHANT_PASSWORD}

client = EyecueIpayout.new()

puts 'Call eWallet_GetCustomerDetails'
service = client.get_service('get_customer_details')
options_hash   = assign_param_values(params, service.parameters)
response = client.ewallet_request(options_hash)
byebug

response
# service = EyecueIpayout::Service.new("eWallet_RegisterUser")
# service.add_param('fn', 'String', true)
# service.add_param('endpoint', 'String', true)
# service.add_param('MerchantGUID', 'String', true)
# service.add_param('MerchantPassword', 'String', true)
# service.add_param('UserName', 'String', true)
# service.add_param('FirstName', 'String', true)
# service.add_param('FirstName', 'String', true)
# service.add_param('LastName', 'String', true)
# service.add_param('CompanyName', 'String', true)
# service.add_param('Address1', 'String', true)
# service.add_param('Address2', 'String', true)
# service.add_param('City', 'String', true)
# service.add_param('State', 'String', true)
# service.add_param('ZipCode', 'String', true)
# service.add_param('Country2xFormat', 'String', true)
# service.add_param('PhoneNumber', 'String', true)
# service.add_param('CellPhoneNumber', 'String', false)
# service.add_param('EmailAddress', 'String', true)
# service.add_param('SSN', 'String', false)
# service.add_param('CompanyTaxID', 'String', false)
# service.add_param('GovernmentID', 'String', false)
# service.add_param('MilitaryID', 'String', false)
# service.add_param('PassportNumber', 'String', false)
# service.add_param('DriversLicense', 'String', false)
# service.add_param('DateOfBirth', 'String', true)
# service.add_param('WebsitePassword', 'String', true)
# service.add_param('DefaultCurrency', 'String', true)
# service.add_param('SkipAutoSVCOrder', 'String', false)
# service.add_param('PreferredLanguage', 'String', false)
# service.add_param('IsBusinessUser', 'String', false)
# service.add_param('BusinessUserName', 'String', false)

# service.response_parameters = ['m_Code', 'm_Text', 'LogTransactionID',
#                                'TransactionRefID', 'ACHTransactionID',
#                                'ProcessorTransactionRefNumber',
#                                'CustomerFeeAmount', 'CurrencyCode']


# byebug

################################
# eWallet_RegisterUser - OK
# eWallet_GetCurrencyBalance - OK
# eWallet_GetCustomerDetails - OK
# eWallet_Load - OK
# eWallet_GetUserAccountStatus - OK
# eWallet_RequestUserAutoLogin
###############################

################### eWallet_RegisterUser #######################################
# params_hash = {}
# params_hash[:fn] = 'eWallet_RegisterUser'
# params_hash[:endpoint] = 'https://testewallet.com/eWalletWS/ws_JsonAdapter.aspx'
# params_hash[:MerchantGUID] =IPAYOUT_MERCHANT_GUID
# params_hash[:MerchantPassword] =IPAYOUT_MERCHANT_PASSWORD
# params_hash[:UserName] = 'dmcalerney'
# params_hash[:FirstName] = 'Danny'
# params_hash[:LastName] = 'McAlerney'
# params_hash[:CompanyName] = 'EyeCue Lab'
# params_hash[:Address1] = '2332 NE Jarrett St.'
# params_hash[:Address2] = ''
# params_hash[:City] = 'Portland'
# params_hash[:State] = 'OR'
# params_hash[:ZipCode] = '97211'
# params_hash[:Country2xFormat] = 'US'
# params_hash[:PhoneNumber] = '5039262516'
# params_hash[:CellPhoneNumber] = '5039262516'
# params_hash[:EmailAddress] = 'daniel.mcalerney@eyecuelab.com'
# params_hash[:SSN] = ''
# params_hash[:CompanyTaxID] = ''
# params_hash[:GovernmentID] = ''
# params_hash[:MilitaryID] = ''
# params_hash[:PassportNumber] = ''
# params_hash[:DriversLicense] = ''
# params_hash[:DateOfBirth] = '10/17/1980'
# params_hash[:WebsitePassword] = ''
# params_hash[:DefaultCurrency] = 'USD'
# params_hash[:SkipAutoSVCOrder] = ''
# params_hash[:PreferredLanguage] = ''
# params_hash[:IsBusinessUser] = ''
# params_hash[:BusinessUserName] = ''
# response = client.register_user(params_hash.to_json, {})
################### eWallet_RegisterUser #######################################


################### eWallet_GetCustomerDetails#######################################
# params_hash = {}
# params_hash[:fn] = 'eWallet_GetCustomerDetails'
# params_hash[:endpoint] = IPAYOUT_API_ENDPOINT
# params_hash[:MerchantGUID] = IPAYOUT_MERCHANT_GUID
# params_hash[:MerchantPassword] = IPAYOUT_MERCHANT_PASSWORD
# params_hash[:UserName] = 'dmcalerney'
# response = client.ewallet_request(params_hash)

# "{'fn':'eWallet_GetCustomerDetails','endpoint':'https://testewallet.com/eWalletWS/ws_JsonAdapter.aspx','MerchantGUID':'a4739056-7db6-40f3-9618-f2bcccbf70cc','MerchantPassword':'9xXLvA66hi','UserName':'dmcalerney'}"

################### eWallet_GetCustomerDetails#######################################

################### eWallet_Load #######################################
#notes:
# MerchantReferenceId is our system's payout transaction id.  it'll be use for callbacks

# SUCCESSFUL RESPONSE
# {"m_Code"=>0,
#  "m_Text"=>"OK",
#  "LogTransactionID"=>0,
#  "TransactionRefID"=>33095,
#  "ACHTransactionID"=>0,
#  "ProcessorTransactionRefNumber"=>"",
#  "CustomerFeeAmount"=>0.0,
#  "CurrencyCode"=>nil}

# params_hash = {}
# params_hash[:fn] = 'eWallet_Load',
# params_hash[:MerchantGUID] =IPAYOUT_MERCHANT_GUID,
# params_hash[:MerchantPassword] =IPAYOUT_MERCHANT_PASSWORD,
# params_hash[:PartnerBatchID] = DateTime.now.to_s,
# params_hash[:PoolID] = '',
# params_hash[:arrAccounts] = [{:UserName => 'dmcalerney', :Amount => 20.50, :Comments => 'Test Test Test', :MerchantReferenceID => 'a4739056-7db6-40f3-9618-f2bcccbf70cc'}],
# params_hash[:AllowDuplicates] = true,
# params_hash[:AutoLoad] = true,
# params_hash[:CurrencyCode] = 'USD'
# response = client.eWallet_request(params_hash, {})
################### eWallet_Load #######################################


################### eWallet_GetUserAccountStatus ###############################
# params_hash = {}
# params_hash[:fn] = 'eWallet_GetUserAccountStatus'
# params_hash[:endpoint] = 'https://testewallet.com/eWalletWS/ws_JsonAdapter.aspx'
# params_hash[:MerchantGUID] =IPAYOUT_MERCHANT_GUID
# params_hash[:MerchantPassword] =IPAYOUT_MERCHANT_PASSWORD
# params_hash[:UserName] = 'dmcalerney'
# response = client.eWallet_request(params_hash, {})
################### eWallet_GetUserAccountStatus ###############################

################### eWallet_GetCurrencyBalance #################################
# params_hash = {}
# params_hash[:fn] = 'eWallet_GetCurrencyBalance'
# params_hash[:endpoint] = 'https://testewallet.com/eWalletWS/ws_JsonAdapter.aspx'
# params_hash[:MerchantGUID] =IPAYOUT_MERCHANT_GUID
# params_hash[:MerchantPassword] =IPAYOUT_MERCHANT_PASSWORD
# params_hash[:UserName] = 'dmcalerney'
# params_hash[:CurrencyCode] = 'USD'
# response = client.eWallet_request(params_hash, {})
################### eWallet_GetCurrencyBalance #################################

################### eWallet_RequestUserAutoLogin #################################
# SUCCESSFUL RESPONSE
#   {"m_Code"=>0,
#    "m_Text"=>"OK",
#    "LogTransactionID"=>0,
#    "TransactionRefID"=>0,
#    "ACHTransactionID"=>0,
#    "ProcessorTransactionRefNumber"=>"44114e78-5932-4b57-a325-a6c60794e67b",
#    "CustomerFeeAmount"=>0.0,
#    "CurrencyCode"=>nil}

# params_hash = {}
# params_hash[:fn] = 'eWallet_RequestUserAutoLogin'
# params_hash[:endpoint] = 'https://testewallet.com/eWalletWS/ws_JsonAdapter.aspx'
# params_hash[:MerchantGUID] =IPAYOUT_MERCHANT_GUID
# params_hash[:MerchantPassword] =IPAYOUT_MERCHANT_PASSWORD
# params_hash[:UserName] = 'dmcalerney'
# response = client.eWallet_request(params_hash, {})
################### eWallet_RequestUserAutoLogin #################################

byebug
puts '!!!!!!!END!!!!!!!'
puts ''
