Airbrake.configure do |config|
  config.api_key = '5743f6c793c623d7b7dc833e396d887b'
  config.environment_name = ENV['AIRBRAKE_ENV'] || Rails.env
end
