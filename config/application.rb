require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
require 'csv'

module Sunstand
  class Application < Rails::Application
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      address:              'smtp.mandrillapp.com',
      port:                 587,
      domain:               'eyecuelab.com',
      user_name:            'paul.walker@eyecuelab.com',
      password:             'TrCgMfSpdGnbfztgaiAuvQ',
      authentication:       'plain',
      enable_starttls_auto: true  }
    config.action_mailer.default_url_options = \
      { host: ENV['EMAIL_HOST'] || 'http://localhost:3000' }
    config.action_mailer.default_options = {
      from: "SunStand <no-reply#{Rails.env}@sunstand.com>" }

    config.paperclip_defaults = {
      storage:        :s3,
      s3_credentials: {
        bucket:            Rails.application.secrets.aws_bucket,
        access_key_id:     Rails.application.secrets.aws_access_key_id,
        secret_access_key: Rails.application.secrets.aws_secret_access_key } }

    config.active_record.schema_format = :sql
    ActiveSupport::Notifications.unsubscribe 'render_partial.action_view'
    config.middleware.delete Rack::ETag
  end
end
