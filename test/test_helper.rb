ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
Dir[Rails.root.join('test/support/**/*.rb')].each { |f| require f }
Minitest::Reporters.use! Minitest::Reporters::DefaultReporter.new(:color => true)

ActiveRecord::FixtureSet.context_class.send :include, TestPasswordHelper
ActionController::TestCase.include TestFunctionalHelpers

class ActiveSupport::TestCase
  include TestPasswordHelper  
  include TestResponse
  include FactoryGirl::Syntax::Methods

  fixtures :all
end
