require 'byebug'
require 'eyecue_ipayout'
require 'json'
require 'date'

IPAYOUT_API_ENDPOINT = 'https://testewallet.com/eWalletWS/ws_JsonAdapter.aspx'
IPAYOUT_MERCHANT_GUID = 'a4739056-7db6-40f3-9618-f2bcccbf70cc'
IPAYOUT_MERCHANT_PASSWORD = '9xXLvA66hi'

ENV['IPAYOUT_API_ENDPOINT'] = IPAYOUT_API_ENDPOINT
ENV['IPAYOUT_MERCHANT_GUID'] = IPAYOUT_MERCHANT_GUID
ENV['IPAYOUT_MERCHANT_PASSWORD'] = IPAYOUT_MERCHANT_PASSWORD

################################
# eWallet_RegisterUser - OK
# eWallet_GetCurrencyBalance - OK
# eWallet_GetCustomerDetails - OK 
# eWallet_Load - OK
# eWallet_GetUserAccountStatus - OK
# eWallet_RequestUserAutoLogin
###############################

ipayout_client_options = {:IPAYOUT_API_ENDPOINT => IPAYOUT_API_ENDPOINT, :IPAYOUT_MERCHANT_GUID => IPAYOUT_MERCHANT_GUID, :IPAYOUT_MERCHANT_PASSWORD=>IPAYOUT_MERCHANT_PASSWORD}
client = EyecueIpayout.new()


################### eWallet_RegisterUser #######################################
options_hash = {}
options_hash[:fn] = 'eWallet_RegisterUser'
options_hash[:endpoint] = 'https://testewallet.com/eWalletWS/ws_JsonAdapter.aspx'
options_hash[:MerchantGUID] =IPAYOUT_MERCHANT_GUID
options_hash[:MerchantPassword] =IPAYOUT_MERCHANT_PASSWORD 
options_hash[:UserName] = 'dmcalerney'
options_hash[:FirstName] = 'Danny'
options_hash[:LastName] = 'McAlerney'
options_hash[:CompanyName] = 'EyeCue Lab'
options_hash[:Address1] = '2332 NE Jarrett St.'
options_hash[:Address2] = ''
options_hash[:City] = 'Portland'
options_hash[:State] = 'OR'
options_hash[:ZipCode] = '97211'
options_hash[:Country2xFormat] = 'US'
options_hash[:PhoneNumber] = '5039262516'
options_hash[:CellPhoneNumber] = '5039262516'
options_hash[:EmailAddress] = 'daniel.mcalerney@eyecuelab.com'
options_hash[:SSN] = ''
options_hash[:CompanyTaxID] = ''
options_hash[:GovernmentID] = ''
options_hash[:MilitaryID] = ''
options_hash[:PassportNumber] = ''
options_hash[:DriversLicense] = ''
options_hash[:DateOfBirth] = '10/17/1980'
options_hash[:WebsitePassword] = ''
options_hash[:DefaultCurrency] = 'USD'
options_hash[:SkipAutoSVCOrder] = ''
options_hash[:PreferredLanguage] = ''
options_hash[:IsBusinessUser] = ''
options_hash[:BusinessUserName] = ''
response = client.register_user(options_hash.to_json, {})
################### eWallet_RegisterUser #######################################


################### eWallet_GetCustomerDetails#######################################
options_hash = {}
options_hash[:fn] = 'eWallet_GetCustomerDetails'
options_hash[:endpoint] = IPAYOUT_API_ENDPOINT
options_hash[:MerchantGUID] = IPAYOUT_MERCHANT_GUID
options_hash[:MerchantPassword] = IPAYOUT_MERCHANT_PASSWORD
options_hash[:UserName] = 'dmcalerney'
response = client.eWallet_request(options_hash, {})

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

# options_hash = {}
# options_hash[:fn] = 'eWallet_Load',
# options_hash[:MerchantGUID] =IPAYOUT_MERCHANT_GUID,
# options_hash[:MerchantPassword] =IPAYOUT_MERCHANT_PASSWORD,
# options_hash[:PartnerBatchID] = DateTime.now.to_s,
# options_hash[:PoolID] = '',
# options_hash[:arrAccounts] = [{:UserName => 'dmcalerney', :Amount => 20.50, :Comments => 'Test Test Test', :MerchantReferenceID => 'a4739056-7db6-40f3-9618-f2bcccbf70cc'}],
# options_hash[:AllowDuplicates] = true,
# options_hash[:AutoLoad] = true,
# options_hash[:CurrencyCode] = 'USD'
# response = client.eWallet_request(options_hash, {})
################### eWallet_Load #######################################


################### eWallet_GetUserAccountStatus ###############################
# options_hash = {}
# options_hash[:fn] = 'eWallet_GetUserAccountStatus'
# options_hash[:endpoint] = 'https://testewallet.com/eWalletWS/ws_JsonAdapter.aspx'
# options_hash[:MerchantGUID] =IPAYOUT_MERCHANT_GUID
# options_hash[:MerchantPassword] =IPAYOUT_MERCHANT_PASSWORD
# options_hash[:UserName] = 'dmcalerney'
# response = client.eWallet_request(options_hash, {})
################### eWallet_GetUserAccountStatus ###############################

################### eWallet_GetCurrencyBalance #################################
# options_hash = {}
# options_hash[:fn] = 'eWallet_GetCurrencyBalance'
# options_hash[:endpoint] = 'https://testewallet.com/eWalletWS/ws_JsonAdapter.aspx'
# options_hash[:MerchantGUID] =IPAYOUT_MERCHANT_GUID
# options_hash[:MerchantPassword] =IPAYOUT_MERCHANT_PASSWORD
# options_hash[:UserName] = 'dmcalerney'
# options_hash[:CurrencyCode] = 'USD'
# response = client.eWallet_request(options_hash, {})
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

# options_hash = {}
# options_hash[:fn] = 'eWallet_RequestUserAutoLogin'
# options_hash[:endpoint] = 'https://testewallet.com/eWalletWS/ws_JsonAdapter.aspx'
# options_hash[:MerchantGUID] =IPAYOUT_MERCHANT_GUID
# options_hash[:MerchantPassword] =IPAYOUT_MERCHANT_PASSWORD
# options_hash[:UserName] = 'dmcalerney'
# response = client.eWallet_request(options_hash, {})
################### eWallet_RequestUserAutoLogin #################################

byebug
puts '!!!!!!!END!!!!!!!'
puts ''
