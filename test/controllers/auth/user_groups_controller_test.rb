require 'test_helper'

class Auth::UserGroupsControllerTest < ActionController::TestCase
 
  test 'index' do
    get :index

    expected = UserGroup.count
    siren.must_have_entity_size(expected)
    siren.wont_have_action(:create)
  end

  test 'index for rank' do
    get :index, rank_id: ranks(:one).id

    siren.must_have_entity_size(1)
  end

  test 'show' do
    get :show, id: user_groups(:rank1).id

    siren.must_be_class(:user_group)
    siren.wont_have_action(:update)
    siren.must_have_entity('user_group-requirements')
  end

  test 'secured actions' do
    post :create, id: 'foo', title: 'foo'
    response.status.must_equal 401

    patch :update, id: user_groups(:rank1).id, title: 'foo'
    response.status.must_equal 401

    delete :destroy, id: user_groups(:rank1).id
    response.status.must_equal 401
  end

  class AdminTest < ActionController::TestCase
    def setup
      super(:admin)
    end

    test 'index' do
      get :index

      siren.must_have_action(:create)
    end

    test 'show' do
      get :show, id: user_groups(:rank1).id

      siren.must_have_action(:update)
      siren.must_have_action(:delete)
    end

    test 'create' do
      post :create, id: 'foo', title: 'foo'

      siren.props_must_equal(title: 'foo')
    end

    test 'update' do
      patch :update, id: user_groups(:rank1).id, title: 'foo'

      siren.props_must_equal(title: 'foo')
    end

    test 'delete' do
      delete :destroy, id: user_groups(:rank1).id

      siren.must_be_class(:user_groups)
    end

    test 'add_rank' do
      post :add_to_rank,
           rank_id: ranks(:one).id,
           id:      user_groups(:orphan).id

      siren.must_have_entity_size(2)
    end
  end
end
