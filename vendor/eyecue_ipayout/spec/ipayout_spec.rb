require 'spec_helper'
require 'byebug'
require "securerandom"

describe EyecueIpayout do
  subject { EyecueIpayout.new }
    before do
      IPAYOUT_API_ENDPOINT = 'https://testewallet.com/eWalletWS/ws_JsonAdapter.aspx'
      IPAYOUT_MERCHANT_GUID = 'a4739056-7db6-40f3-9618-f2bcccbf70cc'
      IPAYOUT_MERCHANT_PASSWORD = '9xXLvA66hi'
      @client = EyecueIpayout.new()
  end

  it 'should have a version' do
    expect(EyecueIpayout::VERSION).to_not be_nil
  end

  # it 'should register a new user' do
  #   options_hash = {}
  #   options_hash[:fn] = 'eWallet_RegisterUser'
  #   options_hash[:endpoint] = 'IPAYOUT_API_ENDPOINT'
  #   options_hash[:MerchantGUID] =IPAYOUT_MERCHANT_GUID
  #   options_hash[:MerchantPassword] =IPAYOUT_MERCHANT_PASSWORD 
  #   options_hash[:UserName] = 'eyecueTestUser'
  #   options_hash[:FirstName] = 'Glen'
  #   options_hash[:LastName] = 'Danzig'
  #   options_hash[:CompanyName] = 'EyeCue Lab'
  #   options_hash[:Address1] = '3934 NE M L King Blvd'
  #   options_hash[:Address2] = ''
  #   options_hash[:City] = 'Portland'
  #   options_hash[:State] = 'OR'
  #   options_hash[:ZipCode] = '97212'
  #   options_hash[:Country2xFormat] = 'US'
  #   options_hash[:PhoneNumber] = '5038415250'
  #   options_hash[:CellPhoneNumber] = ''
  #   options_hash[:EmailAddress] = 'hello@eyecuelab.com'
  #   options_hash[:SSN] = ''
  #   options_hash[:CompanyTaxID] = ''
  #   options_hash[:GovernmentID] = ''
  #   options_hash[:MilitaryID] = ''
  #   options_hash[:PassportNumber] = ''
  #   options_hash[:DriversLicense] = ''
  #   options_hash[:DateOfBirth] = '10/17/1980'
  #   options_hash[:WebsitePassword] = ''
  #   options_hash[:DefaultCurrency] = 'USD'
  #   options_hash[:SkipAutoSVCOrder] = ''
  #   options_hash[:PreferredLanguage] = ''
  #   options_hash[:IsBusinessUser] = ''
  #   options_hash[:BusinessUserName] = ''
  #   response = @client.eWallet_request(options_hash, {})
  #   puts "!!!!!!!!!!!!!!!!!!!!!"
  #   print response
  #   puts "!!!!!!!!!!!!!!!!!!!!!"
  #   expect(response["m_Text"]).to eq("OK")
  #   expect(response["UserName"]).to eq("eyecueTestUser")
  # end

  it 'should fetch registered users account status' do
    options_hash = {}
    options_hash[:fn] = 'eWallet_GetUserAccountStatus'
    options_hash[:endpoint] = 'https://testewallet.com/eWalletWS/ws_JsonAdapter.aspx'
    options_hash[:MerchantGUID] = IPAYOUT_MERCHANT_GUID
    options_hash[:MerchantPassword] = IPAYOUT_MERCHANT_PASSWORD
    options_hash[:UserName] = 'eyecueTestUser'
    response = @client.eWallet_request(options_hash, {})
    print response
    expect(response["m_Text"]).to eq("OK")
    expect(response).to include("AccStatus")
  end

  it "should fetch registered user's account details" do
    options_hash = {}
    options_hash[:fn] = 'eWallet_GetCustomerDetails'
    options_hash[:endpoint] = IPAYOUT_API_ENDPOINT
    options_hash[:MerchantGUID] = IPAYOUT_MERCHANT_GUID
    options_hash[:MerchantPassword] = IPAYOUT_MERCHANT_PASSWORD
    options_hash[:UserName] = 'eyecueTestUser'
    response = @client.eWallet_request(options_hash, {})
    print response
    expect(response["m_Text"]).to eq("OK")
    expect(response["UserName"]).to eq("eyecueTestUser")
  end

  it "should distribute funds to registered user's account" do
    transaction_hex = SecureRandom.hex(16)
    transaction_hex.insert(-27,"-")
    transaction_hex.insert(-22,"-")
    transaction_hex.insert(-17,"-")
    transaction_hex.insert(-12,"-")

    options_hash = {}
    options_hash[:fn] = 'eWallet_Load',
    options_hash[:MerchantGUID] =IPAYOUT_MERCHANT_GUID,
    options_hash[:MerchantPassword] =IPAYOUT_MERCHANT_PASSWORD,
    options_hash[:PartnerBatchID] = DateTime.now.to_s,
    options_hash[:PoolID] = '',
    options_hash[:arrAccounts] = [{:UserName => 'eyecueTestuser', :Amount => 1.00, :Comments => 'Test Test Test', :MerchantReferenceID => transaction_hex}],
    options_hash[:AllowDuplicates] = true,
    options_hash[:AutoLoad] = true,
    options_hash[:CurrencyCode] = 'USD'
    response = @client.eWallet_request(options_hash, {})
    print response
    expect(response["m_Text"]).to eq("OK")
    expect(response).to include("TransactionRefID")
  end

  it "should fetch registered user's account balance" do
    options_hash = {}
    options_hash[:fn] = 'eWallet_GetCurrencyBalance'
    options_hash[:endpoint] = IPAYOUT_API_ENDPOINT
    options_hash[:MerchantGUID] =IPAYOUT_MERCHANT_GUID
    options_hash[:MerchantPassword] =IPAYOUT_MERCHANT_PASSWORD
    options_hash[:UserName] = 'eyecueTestUser'
    options_hash[:CurrencyCode] = 'USD'
    response = @client.eWallet_request(options_hash, {})
    print response
    expect(response["m_Text"]).to eq("OK")
    expect(response).to include("CurrencyCode")
  end



end