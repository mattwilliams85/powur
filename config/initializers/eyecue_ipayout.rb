Ipayout.configure do |config|
  config.endpoint = ENV['IPAYOUT_API_ENDPOINT']
  config.proxy = ENV['QUOTAGUARDSTATIC_URL']
  config.merchant_guid = ENV['IPAYOUT_MERCHANT_GUID']
  config.merchant_password = ENV['IPAYOUT_MERCHANT_PASSWORD']
end
