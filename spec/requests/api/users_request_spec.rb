require 'spec_helper'

describe '/api/users', type: :request do
  before :each do
    login_api_user
  end

  def expect_children(children)
    children.each do |child|
      result = json_body['entities'].find do |e|
        e['properties']['id'] == child.id
      end
      expect(result).to be
    end
  end

  describe 'GET /' do

    it 'returns the immediate downline users for the current user' do
      children  = create_list(:user, 3, sponsor: @user)
      create_list(:user, 2)

      get api_users_path, token_param

      expect_children(children)
    end

  end

  describe 'GET /:id/downline' do

    it 'returns the immediate downline of a user in the downline' do
      user = create(:user, sponsor: @user)
      children = create_list(:user, 2, sponsor: user)

      get downline_api_user_path(id: user), token_param

      expect(children)
    end

  end
end
