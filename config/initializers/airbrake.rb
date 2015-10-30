Airbrake.configure do |config|
  config.api_key = ENV['AIRBRAKE_API_KEY']
  config.environment_name = ENV['AIRBRAKE_ENV'] || Rails.env
end
