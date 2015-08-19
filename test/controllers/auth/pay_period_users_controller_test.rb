require 'test_helper'

class Auth::PayPeriodUsersControllerTest < ActionController::TestCase

  class AdminTest < ActionController::TestCase
    def test_index
      get :index, pay_period_id: pay_periods(:april).id

      siren.must_be_class(:users)
      user = siren.entities.first
      user.properties.personal.wont_be_nil
      user.properties.bonus_total.wont_be_nil
    end

    def test_show
      get :show, pay_period_id: pay_periods(:april).id, id: users(:advocate).id

      siren.must_have_entity('user-bonus_payments')
      payments = siren.entity('user-bonus_payments')
      payments.must_have_entity_size(1)
    end
  end
end
