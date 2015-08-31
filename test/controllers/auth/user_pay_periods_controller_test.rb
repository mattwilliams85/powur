require 'test_helper'

class Auth::UserPayPeriodsControllerTest < ActionController::TestCase
  def test_index
    get :index, user_id: users(:advocate).id

    siren.must_be_class(:pay_periods)
  end

  def test_show
    get :show, user_id: users(:advocate).id, id: '2015-04'

    siren.must_be_class(:pay_period)
    siren.must_have_entities('user-bonus_totals', 'user-bonus_payments')
  end

  class AdminTest < ActionController::TestCase
  end
end
