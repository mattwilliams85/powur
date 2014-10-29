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

    config.active_record.schema_format = :sql
    # config.action_controller.include_all_helpers = false
    ActiveSupport::Notifications.unsubscribe 'render_partial.action_view'

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    # config.serve_static_assets = true
  end
end
