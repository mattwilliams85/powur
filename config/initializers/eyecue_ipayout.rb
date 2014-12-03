EyecueIpayout.configure do |config|

  config.endpoint =
    Rails.application.secrets.ipayout_api_endpoint
  config.merchant_guid =
    Rails.application.secrets.ipayout_merchant_guid
  config.merchant_password =
    Rails.application.secrets.ipayout_merchant_password
end
