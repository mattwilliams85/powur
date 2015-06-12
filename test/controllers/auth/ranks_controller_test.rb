require 'test_helper'

module Auth
  class RanksControllerTest < ActionController::TestCase

    test 'index' do
      get :index

      siren.must_be_class(:ranks)
      siren.wont_have_action(:create)
    end

    test 'show' do
      get :show, id: ranks(:one)

      siren.must_have_entity('rank-user_groups')
    end

    class AdminTest < ActionController::TestCase
      def setup
        super(:admin)
      end

      test 'index' do
        get :index

        siren.must_have_action(:create)
        siren.must_have_entity_size(2)

        first_rank = siren.entities.first
        first_rank.wont_have_action(:delete)
        last_rank = siren.entities.last
        last_rank.must_have_action(:delete)
      end

      test 'create' do
        post :create, title: 'foo'

        siren.must_be_class(:rank)
        siren.props_must_equal(title: 'foo', id: Rank.count)
      end

      test 'update' do
        patch :update, id: ranks(:one).id, title: 'foo'

        siren.must_be_class(:rank)
        siren.props_must_equal(title: 'foo')
      end

      test 'delete' do
        rank = create(:rank)
        expected = Rank.count - 1

        delete :destroy, id: rank.id

        siren.must_be_class(:ranks)
        siren.must_have_entity_size(expected)
      end
    end
  end
end
