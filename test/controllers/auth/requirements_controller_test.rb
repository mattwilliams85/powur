require 'test_helper'

class Auth::RequirementsControllerTest < ActionController::TestCase
  let(:fixture) { user_group_requirements(:rank1) }

  test 'index' do
    get :index, user_group_id: user_groups(:rank1).id

    siren.must_be_class(:requirements)
    siren.must_have_entity_size(1)
    siren.wont_have_action(:create)
  end

  test 'show' do
    get :show, id: fixture.id

    siren.must_be_class(:requirement)
  end

  class AdminTest < ActionController::TestCase
    def setup
      super(:admin)
    end

    let(:fixture) { user_group_requirements(:rank1) }

    test 'index' do
      get :index, user_group_id: user_groups(:rank1).id

      siren.must_have_action(:create)
      siren.action(:create).must_have_fields(:product_id, :event_type)
    end

    test 'show' do
      get :show, id: fixture.id

      siren.must_have_action(:update)
    end

    test 'create' do
      post :create,
           product_id:    products(:solar).id,
           user_group_id: user_groups(:rank1).id,
           event_type:    'course_enrollment'
    end

    test 'update' do
      patch :update, id:        user_group_requirements(:personal_sales).id,
                     quantity:  10,
                     time_span: 'monthly'

      siren.props_must_equal(quantity: 10, time_span: 'Monthly')
    end

    test 'delete' do
      delete :destroy, id: fixture.id

      siren.must_be_class(:requirements)
    end

  end

end