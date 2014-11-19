# Maybe don't need it after all
EyecueIpayout.configure do |config|
  config.endpoint =
    Rails.application.secrets[:IPAYOUT_API_ENDPOINT]
  config.merchant_guid =
    Rails.application.secrets[:IPAYOUT_MERCHANT_GUID]
  config.merchant_password =
    Rails.application.secrets[:IPAYOUT_MERCHANT_PASSWORD]
    byebug
end