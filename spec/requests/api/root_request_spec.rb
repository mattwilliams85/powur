require 'spec_helper'

describe '/api', type: :request do
  describe 'GET' do
    it 'returns the root API resource' do
      get api_root_path(format: :json)

      expect_actions 'password', 'token', 'refresh_token'
    end

    it 'returns a versioned path to the token when including a version param' do
      get api_root_path(format: :json), v: 1

      token_action = json_body['actions'].find { |a| a['name'] == 'token' }
      expect(token_action).to be
      expect(token_action['href']).to eq(api_token_path(v: 1))
    end

    it 'returns invalid_scope with an unsupported API version' do
      get api_root_path(format: :json), v: 42

      expect_api_error(:invalid_scope)
    end
  end
end
