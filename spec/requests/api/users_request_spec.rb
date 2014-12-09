require 'spec_helper'

describe '/api/users', type: :request do
  before :each do
    login_api_user
  end

  describe 'GET /' do

    it 'returns the immediate downline users for the current user' do
      users = create_list(:user, 3, sponsor: @user)
      create_list(:user, 2)

      get api_users_path, token_param

      expect_entities_count(3)
    end

  end

  describe 'GET /:id/downline' do

    it 'returns the immediate downline of a user in the downline' do
      user = create(:user, sponsor: @user)
      create_list(:user, 2, sponsor: user)

      get downline_api_user_path(id: user), token_param

      expect_entities_count(2)
    end

  end
end
