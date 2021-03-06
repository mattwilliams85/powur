ruby '2.2.2'
source 'https://rubygems.org'

gem 'dotenv-rails', groups:  [ :development, :test ],
                    require: 'dotenv/rails-now'
gem 'rails', '4.2.5'
gem 'pg'

gem 'uglifier'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'jbuilder'
gem 'compass-rails', github: 'Compass/compass-rails', branch: 'master'
gem 'sass-rails'
gem 'autoprefixer-rails'
gem 'angular-rails-templates'

gem 'aws-sdk', '< 2.0'
gem 'paperclip'

gem 'postgres_ext', github: 'dockyard/postgres_ext'
gem 'composite_primary_keys',
    github: 'composite-primary-keys/composite_primary_keys', branch: 'ar_4.2.x'
gem 'active_hash'
gem 'same_time', github: 'paulwalker/same_time'
gem 'bcrypt-ruby', '~> 3.1.2', require: 'bcrypt'
gem 'rails-settings-cached'
gem 'gibbon'
gem 'valid_email'
gem 'faker'
gem 'activerecord_any_of', github: 'oelmekki/activerecord_any_of'
gem 'money'
gem 'has_scope'
gem 'attr_extras'
gem 'faraday'
gem 'httparty'
gem 'delayed_job_active_record'
gem 'airbrake', '4.1.0'
gem 'pry-rails'
gem 'ipayout', github: 'eyecuelab/ipayout'
gem 'week_of_month'
gem 'eventmachine', github: 'eventmachine/eventmachine', branch: :master
gem 'aasm'
gem 'smarteru', github: 'eyecuelab/smarteru'
gem 'figaro'
gem 'hashie'
gem 'twilio-ruby'
gem 'typescript-rails'
gem 'foundation-rails'
gem 'lograge'
gem 'mandrill-api', require: 'mandrill'
gem 'ruby-graphviz', require: 'graphviz'

group :development do
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'thin'
  gem 'rubocop', require: false, github: 'bbatsov/rubocop'
  gem 'meta_request'
  gem 'foreman'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'factory_girl_rails',
      github: 'paulwalker/factory_girl_rails',
      branch: 'allow_file_path_def'
  gem 'awesome_print'
  gem 'byebug'
  gem 'vcr'
end

group :test do
  gem 'database_cleaner'
  gem 'db-query-matchers'
  gem 'capybara'
  gem 'capybara-firebug'
  gem 'minitest-spec-rails'
  gem 'minitest-reporters'
  gem 'm'
  gem 'color_pound_spec_reporter'
  gem 'webmock', require: 'webmock/rspec'
end

gem 'sdoc', '~> 0.4.0', group: :doc

# hosting environment gems
gem 'rails_12factor', group: :production
gem 'unicorn'
