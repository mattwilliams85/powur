require 'test_helper'

class Auth::UsersControllerTest < ActionController::TestCase
  def test_index
    get :index

    siren.must_be_class(:users)
    expected = User.with_ancestor(users(:advocate).id).count
    siren.must_have_entity_size(expected)
  end

  def test_index_sorted_by_name
    get :index, sort: 'name'

    result = siren.entities.map { |e| e.properties.last_name }
    result.must_equal result.sort
  end

  def test_index_sorted_by_totals_not_selected
    skip('need to figure out a way to do this')
    get :index, sort: 'team_count'

    siren.must_be_error
  end

  def test_downline
    get :downline, id: users(:advocate).id

    entity_ids.must_equal advocate_downline.map(&:id).sort
  end

  def test_upline
    get :upline, id: users(:grandchild).id

    entity_ids.must_equal [ users(:advocate).id, users(:child).id ]
  end

  def test_search_downline
    get :downline, id: users(:advocate).id, search: 'gary'

    expected = [ users(:garey).id, users(:garry).id ].sort
    entity_ids.must_equal expected
  end

  def test_downline_with_totals
    get :downline,
        id:          users(:advocate).id,
        item_totals: 'lead_count,team_count',
        sort:        'team_count'

    result = siren.entities.first
    result.props_must_equal(id: users(:child).id)
    result.properties.totals.wont_be_nil
    result.properties.totals.lead_count.wont_be_nil
    result.properties.totals.team_count.wont_be_nil
  end

  def test_show_child
    get :show, id: users(:child).id

    siren.must_be_class(:user)
    siren.must_have_actions(:move)
  end

  def test_show_child_with_user_totals
    get :show, id: users(:child).id, user_totals: true

    siren.properties.totals.wont_be_nil
  end

  def test_show_self
    get :show, id: users(:advocate).id

    siren.must_have_actions(:update)
    siren.wont_have_actions(:move)
  end

  def test_eligible_parents
    get :eligible_parents, id: users(:child).id
    parent_id = users(:child).parent_id

    ids = siren.entities.map(&:properties).map(&:id)
    ids.each do |id|
      User.find(id).upline.must_include parent_id
      id.wont_equal users(:child).id
      id.wont_equal parent_id
    end
  end

  def test_move
    post :move, id: users(:child).id, parent_id: users(:child2).id

    siren.props_must_equal moved: true
    user = User.find(users(:child).id)
    user.parent_id.must_equal users(:child2).id
    users(:grandchild).ancestor?(users(:child2).id).must_equal true
  end

  def test_invalid_move
    post :move, id: users(:child).id, parent_id: users(:grandchild).id

    siren.must_be_error
  end

  private

  def advocate_downline
    User.with_parent(users(:advocate).id)
  end

  def entity_ids
    siren.entity_ids.sort
  end

  class AdminTest < ActionController::TestCase
    def setup
      super(:admin)
    end

    def test_index
      get :index

      siren.must_have_entity_size(User.count)
    end

    def test_downline
      get :downline, id: users(:child).id

      result = siren.entity_ids.sort
      expected = User.with_parent(users(:child).id).map(&:id).sort
      result.must_equal expected
    end
  end
end
