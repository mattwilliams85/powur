require 'test_helper'

class Auth::PayPeriodUsersControllerTest < ActionController::TestCase

  class AdminTest < ActionController::TestCase
    def test_index
      get :index, pay_period_id: pay_periods(:june).id

      siren.must_be_class(:users)
      user = siren.entities.first
      user.properties.personal.wont_be_nil
    end
  end
end
