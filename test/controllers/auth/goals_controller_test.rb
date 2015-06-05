require 'test_helper'

class Auth::GoalsControllerTest < ActionController::TestCase
  test 'show' do
    get :show, user_id: users(:advocate).id

    siren.must_have_class(:goals)
    siren.must_have_entities(
      'goals-user_groups',
      'goals-requirements',
      'goals-enrollments',
      'goals-order_totals')
    enrollments = siren.entity('goals-enrollments')
    enrollments.must_have_entity_size(1)
  end

  test 'show with invalid user_id' do
    get :show, user_id: 'invalid'

    response.status.must_equal 404
  end
end
