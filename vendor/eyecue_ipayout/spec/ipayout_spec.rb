require 'spec_helper'
require 'securerandom'

describe EyecueIpayout do
  subject { EyecueIpayout.new }
  before do
    @client = EyecueIpayout.new
  end

  it 'should have a version' do
    expect(EyecueIpayout::VERSION).to_not be_nil
  end

  describe '#configure' do
    before do
      EyecueIpayout.configure do |config|
        config.endpoint = 'https://testewallet.com/xxxxxx/ws_JsonAdapter.aspx'
        config.merchant_password = "elS0l"
        config.merchant_guid = "1212112121212121"
      end
    end

    it 'returns the values set by configuration' do
      config = EyecueIpayout.configuration
      expect(config.endpoint).to eq('https://testewallet.com/xxxxxx/ws_JsonAdapter.aspx')
      expect(config.merchant_password).to eq('elS0l')
      expect(config.merchant_guid).to eq("1212112121212121")
    end
  end

  describe '.reset' do
    before :each do
      EyecueIpayout.configure do |config|
        config.endpoint = 'https://testewallet.com/000000000/ws_JsonAdapter.aspx'
      end
    end

    it 'resets the configuration' do
      EyecueIpayout.reset

      config = EyecueIpayout.configuration

      expect(config.endpoint).to be_nil
    end
  end

  email_address = 'register-test' + rand.to_s[2..6] + '@eyecuelab.com'
  it 'should register a new user' do

    options_hash = {}
    options_hash[:fn] = 'eWallet_RegisterUser'
    options_hash[:endpoint] = EyecueIpayout.configuration.endpoint
    options_hash[:MerchantGUID] = EyecueIpayout.configuration.merchant_guid
    options_hash[:MerchantPassword] = EyecueIpayout.configuration.merchant_password
    options_hash[:UserName] = email_address
    options_hash[:FirstName] = 'Glen'
    options_hash[:LastName] = 'Danzig'
    options_hash[:CompanyName] = 'EyeCue Lab'
    options_hash[:Address1] = '3934 NE M L King Blvd'
    options_hash[:Address2] = ''
    options_hash[:City] = 'Portland'
    options_hash[:State] = 'OR'
    options_hash[:ZipCode] = '97212'
    options_hash[:Country2xFormat] = 'US'
    options_hash[:PhoneNumber] = '5038415250'
    options_hash[:CellPhoneNumber] = ''
    options_hash[:EmailAddress] = email_address
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
    pp options_hash
    response = @client.ewallet_request(options_hash)

    expect(response['m_Text']).to eq('OK')
  end

  it 'should fetch registered users account status' do
    options_hash = {}
    options_hash[:fn] = 'eWallet_GetUserAccountStatus'
    options_hash[:endpoint] = EyecueIpayout.configuration.endpoint
    options_hash[:MerchantGUID] = EyecueIpayout.configuration.merchant_guid
    options_hash[:MerchantPassword] = EyecueIpayout.configuration.merchant_password
    options_hash[:UserName] = email_address
    response = @client.ewallet_request(options_hash)
    print response
    expect(response['m_Text']).to eq('OK')
    expect(response).to include('AccStatus')
  end

  it 'should fetch registered user\'s account details' do
    options_hash = {}
    options_hash[:fn] = 'eWallet_GetCustomerDetails'
    options_hash[:endpoint] = EyecueIpayout.configuration.endpoint
    options_hash[:MerchantGUID] = EyecueIpayout.configuration.merchant_guid
    options_hash[:MerchantPassword] = EyecueIpayout.configuration.merchant_password
    options_hash[:UserName] = email_address
    response = @client.ewallet_request(options_hash)
    expect(response['m_Text']).to eq('OK')
    expect(response['UserName']).to eq('eyecueTestUser')
  end

  it 'should distribute funds to registered user\'s account' do
    transaction_hex = SecureRandom.hex(16)
    transaction_hex.insert(-27, '-')
    transaction_hex.insert(-22, '-')
    transaction_hex.insert(-17, '-')
    transaction_hex.insert(-12, '-')

    options_hash = {}
    options_hash[:fn]               = 'eWallet_Load'
    options_hash[:endpoint]         = EyecueIpayout.configuration.endpoint
    options_hash[:MerchantGUID]     = EyecueIpayout.configuration.merchant_guid
    options_hash[:MerchantPassword] = EyecueIpayout.configuration.merchant_password
    options_hash[:PartnerBatchID]   = DateTime.now.to_s
    options_hash[:PoolID]           = ''
    options_hash[:arrAccounts]      = [{ UserName: email_address,
                                         Amount:   1.00,
                                         Comments: 'Test Test Test',
                                         MerchantReferenceID:
                                         transaction_hex }]
    options_hash[:AllowDuplicates]  = true
    options_hash[:AutoLoad]         = true
    options_hash[:CurrencyCode]     = 'USD'
    response = @client.ewallet_request(options_hash)
    print response
    expect(response['m_Text']).to eq('OK')
    expect(response).to include('TransactionRefID')
  end

  it 'should fetch registered user\'s account balance' do
    options_hash = {}
    options_hash[:fn] = 'eWallet_GetCurrencyBalance'
    options_hash[:endpoint] = EyecueIpayout.configuration.endpoint
    options_hash[:MerchantGUID] = EyecueIpayout.configuration.merchant_guid
    options_hash[:MerchantPassword] = EyecueIpayout.configuration.merchant_password
    options_hash[:UserName] = email_address
    options_hash[:CurrencyCode] = 'USD'
    response = @client.ewallet_request(options_hash)
    print response
    expect(response['m_Text']).to eq('OK')
    expect(response).to include('CurrencyCode')
  end
end
