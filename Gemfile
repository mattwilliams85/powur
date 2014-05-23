ruby '2.1.1'
source 'https://rubygems.org'

gem 'rails', '4.1.0'
gem 'pg'
gem 'sass-rails', '~> 4.0.3'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'jquery-rails'
gem 'jquery-turbolinks'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'

gem 'active_hash'
gem 'pry'
gem 'same_time', github: 'paulwalker/same_time'
gem 'bcrypt-ruby', '~> 3.1.2', require: 'bcrypt'
gem 'rails-settings-cached'
gem 'gibbon'
gem 'valid_email', require: 'valid_email/email_validator'

group :development do
  gem 'spring'
  gem 'thin'
end

group :development, :test do
  gem 'rspec-rails', '= 3.0.0.beta2'
  gem 'factory_girl_rails'
  gem 'awesome_print'
  # gem 'debugger'
end

group :test do
  gem 'database_cleaner'
  gem 'webmock', require: 'webmock/rspec'
  gem 'vcr'
end

gem 'sdoc', '~> 0.4.0', group: :doc

# hosting environment gems
gem 'rails_12factor', group: :production
gem 'unicorn'

