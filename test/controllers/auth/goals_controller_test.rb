require 'test_helper'

class Auth::GoalsControllerTest < ActionController::TestCase
  test 'show' do
    get :show, user_id: users(:advocate).id

    siren.must_have_class(:goals)
    siren.must_have_entities('goals-requirements')
  end

  # test 'show with invalid user_id' do
  #   get :show, user_id: 'invalid'

  #   response.status.must_equal 404
  # end
end
