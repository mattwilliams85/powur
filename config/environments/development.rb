Rails.application.configure do

  config.cache_classes = false
  config.eager_load = false

  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  config.action_mailer.raise_delivery_errors = false

  config.active_support.deprecation = :log

  config.active_record.migration_error = :page_load

  config.assets.debug = true
  config.assets.raise_runtime_errors = true

  config.action_view.raise_on_missing_translations = true

  config.action_mailer.default_url_options = { host: 'localhost:3000' }
  config.action_mailer.default_options = {
    from: 'EyeCueLab Local Mailer <no-reply+local@eyecuelab.com>' }
  config.action_controller.asset_host = "http://#{config.action_mailer.default_url_options[:host]}"


  config.paperclip_defaults = {
    :storage => :s3,
    :s3_credentials => {
      :bucket => "sunstand-dev",
      :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
      :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
    }
  }

end
