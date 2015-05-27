require 'test_helper'

class Auth::GoalsControllerTest < ActionController::TestCase

  test 'show' do
    get :show, user_id: users(:advocate).id

    siren.must_have_class(:goals)
    siren.must_have_entities(
      'goals-user_groups',
      'goals-requirements',
      'goals-enrollments')
    enrollments = siren.entity('goals-enrollments')
    enrollments.must_have_entity_size(1)
  end

end
