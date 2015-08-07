ENV['MINITEST'] ||= '1'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

Dir[Rails.root.join('test/support/**/*.rb')].each { |f| require f }
reporter = Minitest::Reporters::DefaultReporter.new(color: true)
Minitest::Reporters.use! reporter

ActiveRecord::FixtureSet.context_class.send :include, TestPasswordHelper
ActionController::TestCase.include TestFunctionalHelpers

class ActiveSupport::TestCase
  include TestPasswordHelper
  include TestResponse
  include FactoryGirl::Syntax::Methods

  fixtures :all
end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
  c.ignore_localhost = true
end
