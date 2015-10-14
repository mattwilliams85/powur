require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
require 'csv'

module Powur
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
    email_host = ENV['EMAIL_HOST'] || 'http://localhost:3000'
    config.action_mailer.default_url_options = { host: email_host }
    config.action_mailer.default_options = {
      from: "Powur <no-reply#{Rails.env}@powur.com>" }

    config.paperclip_defaults = {
      storage:        :s3,
      s3_credentials: {
        bucket:            ENV['AWS_BUCKET'],
        access_key_id:     ENV['AWS_ACCESS_KEY_ID'],
        secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'] } }

    config.active_record.schema_format = :sql
    config.active_record.raise_in_transactional_callbacks = true
    ActiveSupport::Notifications.unsubscribe 'render_partial.action_view'
    config.middleware.delete Rack::ETag

    config.assets.paths << Rails.root.join('app', 'assets', 'templates')
    # config.assets.paths << Rails.root.join('app', 'assets', 'components')
    config.assets.paths << Rails.root.join('vendor',
                                           'assets',
                                           'bower_components')
    # config.angular_templates.inside_paths = [ Rails.root.join('app', 'assets', 'javascripts') ]

    config.assets.paths << Rails.root.join('app', 'assets', 'client', 'app')

    locales_path = Rails.root.join('config', 'locales', '**', '*.yml')
    config.i18n.load_path += Dir[ locales_path ]

    config.secret_key_base = ENV['SECRET_KEY_BASE']

    # For hosted PDFs (Application and Agreement)
    config.assets.paths << Rails.root.join('app', 'assets', 'documents')

    # Disable log lines for rendering views
    config.action_view.logger = nil

    config.active_job.queue_adapter = :delayed_job

    # https://github.com/Microsoft/TypeScript/issues/1232
    Typescript::Rails::Compiler.default_options = ['--target', 'ES5']
    # Typescript::Rails::Compiler
    #   .default_options.push('--suppressImplicitAnyIndexErrors')
    # binding.pry
  end
end
