require 'spec_helper'

describe '/api/session', type: :request do
  describe 'GET' do
    it 'requires a valid token' do
      get api_session_path(format: :json)

      expect_api_error(:invalid_token)
    end

    it 'returns an invalid_grant when the access_token is expired' do
      token = create(:expired_token)

      get api_session_path(format: :json),
          nil,
          bearer_header(token.access_token)

      expect_api_error(:invalid_grant)
    end

    it 'returns the session with a valid bearer token header' do
      get api_session_path(format: :json), { v: 1 }, api_header

      expect_classes 'session'
      expect_entities 'user-leads', 'user-invites',
                      'user-children', 'session-user'
    end

    it 'returns the session with a valid bearer token parameter' do
      get api_session_path(v: 1, format: :json), token_param

      expect_classes 'session'
    end
  end
end
