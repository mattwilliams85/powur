require 'spec_helper'

describe '/a/users' do

  before :each do
    login_user
  end

  describe '#index' do

    it 'returns level 1 users' do
      create_list(:user, 3)

      get admin_users_path, format: :json

      expect_200

      expect_classes('users', 'list')
      expect(json_body['entities'].size).to eq(4)
    end

    it 'requires the user to be an admin' do
      @user.roles = []
      @user.save!

      get admin_users_path, format: :json

      expect(json_body.keys).to include('redirect')
    end

  end
end