require 'spec_helper'

describe '/users' do

  before :each do
    login_user
  end

  describe '#index' do

    it 'returns a list of the users belonging to the current user' do
      create_list(:user, 8, invitor: @user)

      get users_path, format: :json

      expect_200

      expect_classes('users', 'list')
      expect(json_body['entities'].size).to eq(8)
    end

  end

  describe '#search' do

    it 'searches a list of users belong to the current user' do
      user1 = create(:user, invitor: @user, first_name: 'davey')
      user2 = create(:user, invitor: @user, last_name: 'sedavos')
      user3 = create(:user, invitor: @user, email: 'redavid@example.org')
      create_list(:user, 2, invitor: @user)

      get users_path, q: 'dav', format: :json

      expect_200
      expect(json_body['entities'].size).to eq(3)
      result_ids = json_body['entities'].map { |u| u['properties']['id'] }

      expect(result_ids).to include(user1.id, user2.id, user3.id)
    end

  end

  describe '/:id' do

    it 'returns the user detail' do
      user = create(:user, invitor: @user)
      get user_path(user), format: :json

      expect_200
    end

  end


end