ruby '2.1.1'
source 'https://rubygems.org'

gem 'rails', '4.1.4'
gem 'pg'
gem 'sass-rails', '~> 4.0.3'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'jquery-rails'
gem 'jquery-turbolinks'
gem 'turbolinks'
gem 'jbuilder'#, '~> 2.0', github: 'rails/jbuilder', branch: 'additive_blocks'

gem 'postgres_ext', github: 'dockyard/postgres_ext', branch: 'rails4.1'
gem 'composite_primary_keys'
gem 'active_hash'
gem 'same_time', github: 'paulwalker/same_time'
gem 'bcrypt-ruby', '~> 3.1.2', require: 'bcrypt'
gem 'rails-settings-cached'
gem 'gibbon'
gem 'valid_email', require: 'valid_email/email_validator'
gem 'foreigner', github: 'matthuhiggins/foreigner'
gem 'faker'


gem 'pry-rails'

group :development do
  gem 'spring'
  gem 'thin'
end

group :development, :test do
  gem 'rspec-rails'
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

