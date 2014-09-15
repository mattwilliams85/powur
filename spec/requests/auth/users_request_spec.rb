require 'spec_helper'

describe '/u/users' do

  before :each do
    login_user
  end

  describe '#index' do

    it 'returns a list of the users belonging to the current user' do
      create_list(:user, 8, sponsor: @user)

      get users_path, format: :json

      expect_200

      expect_classes('users', 'list')
      expect(json_body['entities'].size).to   eq(8)
    end

  end

  describe '#search' do

    it 'searches a list of users belong to the current user' do
      user1 = create(:user, sponsor: @user, first_name: 'davey')
      user2 = create(:user, sponsor: @user, last_name: 'david')
      user3 = create(:user, sponsor: @user, email: 'redave@example.org')
      create_list(:user, 2, sponsor: @user, first_name: 'Mary', last_name: 'Jones')

      get users_path, search: 'dave', format: :json

      expect(json_body['entities'].size).to eq(3)
      result_ids = json_body['entities'].map { |u| u['properties']['id'] }

      expect(result_ids).to include(user1.id, user2.id, user3.id)
    end

  end

  describe '/:id' do

    it 'returns not found with an invalid user id' do
      get user_path(42), format: :json

      expect_alert_error
    end

    it 'returns the user detail' do
      user = create(:user, sponsor: @user)
      get user_path(user), format: :json

      expect_200
    end

  end

  describe '/u/users/:id/downline' do
    it 'returns the downline users' do
      child = create_list(:user, 3, sponsor: @user).first

      create_list(:user, 2, sponsor: child)

      get downline_user_path(@user), format: :json

      expect_200

      found_child = json_body['entities'].find { |e| e['properties']['id'] == child.id }
      expect(found_child).to_not be_nil
      expect(found_child['properties']['downline_count']).to eq(2)
    end
  end


  describe '/u/users/:id/upline' do
    it 'returns the upline users' do
      grand_parent = create(:user, sponsor: @user, first_name: 'Pappy')
      parent = create(:user, sponsor: grand_parent, first_name: 'Parent')
      child = create(:user, sponsor: parent, first_name: 'Child')
      
      get upline_user_path(child), format: :json

      expect_200

      found_parent = json_body['entities'].find { |e| e['properties']['id'] == parent.id }
      found_grand_parent = json_body['entities'].find { |e| e['properties']['id'] == grand_parent.id }
      expect(found_parent).to_not be_nil
      expect(found_grand_parent).to_not be_nil
      expect(json_body['entities'].count).to eq(3)
    end
  end

end
