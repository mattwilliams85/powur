require 'spec_helper'

describe '/api/users', type: :request do
  before :each do
    login_api_user
  end

  describe 'GET /' do

    it 'returns the immediate downline users for the current user' do
      create_list(:user, 3, sponsor: @user)
      create_list(:user, 2)

      get api_users_path, token_param
    end

  end
end
