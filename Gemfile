ruby '2.2.2'
source 'https://rubygems.org'

gem 'dotenv-rails', groups: [:development, :test]

gem 'rails', '4.2.1'
gem 'pg'

gem 'sass-rails'
gem 'uglifier'
gem 'jquery-rails'
gem 'jbuilder'
gem 'compass-rails', github: 'Compass/compass-rails', branch: 'master'
gem 'angular-rails-templates'

gem 'aws-sdk', '< 2.0'
gem 'paperclip'
gem 'carrierwave'
gem 'carrierwave_direct'
gem 's3_direct_upload'

gem 'postgres_ext', github: 'dockyard/postgres_ext'
gem 'composite_primary_keys', github: 'composite-primary-keys/composite_primary_keys', branch: 'ar_4.2.x'
gem 'active_hash'
gem 'same_time', github: 'paulwalker/same_time'
gem 'bcrypt-ruby', '~> 3.1.2', require: 'bcrypt'
gem 'rails-settings-cached'
gem 'gibbon'
gem 'valid_email', require: 'valid_email/email_validator'
gem 'faker'
gem 'activerecord_any_of', github: 'oelmekki/activerecord_any_of'
gem 'money'
gem 'has_scope'
gem 'attr_extras'
gem 'faraday'
gem 'httparty'
gem 'delayed_job_active_record'
gem 'airbrake'
gem 'pry-rails'
gem 'ipayout', github: 'eyecuelab/ipayout'
gem 'week_of_month'
gem 'eventmachine', github: 'eventmachine/eventmachine', branch: :master
gem 'newrelic_rpm'
gem 'aasm'
gem 'smarteru', github: 'eyecuelab/smarteru'
gem 'figaro'

group :development do
  gem 'spring-commands-rspec'
  gem 'thin'
  gem 'rubocop', require: false
  gem 'meta_request'
  gem 'foreman'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'awesome_print'
  gem 'byebug'
  gem 'vcr'
end

group :test do
  gem 'database_cleaner'
  gem 'webmock', require: 'webmock/rspec'
  gem 'db-query-matchers'
  gem 'capybara'
  gem 'capybara-firebug'
end

gem 'sdoc', '~> 0.4.0', group: :doc

# hosting environment gems
gem 'rails_12factor', group: :production
gem 'unicorn'
