require 'test_helper'

class Auth::GoalsControllerTest < ActionController::TestCase
  test 'show' do
    get :show, user_id: users(:advocate).id

    siren.must_have_class(:goals)
    siren.must_have_entity('goals-user_groups')
    siren.must_have_entity('goals-requirements')
  end

end
