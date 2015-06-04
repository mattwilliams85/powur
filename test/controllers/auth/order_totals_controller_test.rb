require 'test_helper'

class Auth::OrderTotalsControllerTest < ActionController::TestCase
  test 'index for user' do
    get :index, user_id: users(:advocate).id

    siren.must_be_class('order_totals')
    siren.self_link.must_include 'users'

    totals = siren.entities.first
    totals.props_must_equal(
      personal: 1,
      group:    1, 
      user:     users(:advocate).full_name)
  end

  it 'index for pay period' do
    get :index, pay_period_id: pay_periods(:monthly).id, sort: 'user'

    siren.must_be_class('order_totals')
    siren.self_link.must_include 'pay_periods'
  end
end
