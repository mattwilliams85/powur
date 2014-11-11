require 'spec_helper'

describe '/api/token', type: :request do

  before :each do
    @client = create(:api_client)
  end

  it 'requires a valid client' do
    post api_token_path

    expect_api_error(:invalid_client)
  end

  describe 'valid client' do
    def post_token(params)
      post api_token_path, params, authorize_header(@client)
    end

    def expect_token
      %w(access_token token_type expires_in refresh_token).each do |key|
        expect(json_body[key]).to be
      end
    end

    it 'needs the client to exist' do
      ApiClient.destroy_all
      user = create(:user)
      post_token username:   user.email,
                 password:   'password',
                 grant_type: 'password'

      expect_api_error(:invalid_client)
    end

    it 'requires a grant_type paramter' do
      post_token(nil)

      expect_api_error
    end

    it 'requires a valid grant_type paramter' do
      post_token grant_type: 'foo'

      expect_api_error(:unsupported_grant_type)
    end

    describe '#ropc' do
      it 'requires username and password parameters' do
        post_token grant_type: 'password'
        expect_api_error

        post_token username: 'foo', grant_type: 'password'
        expect_api_error

        post_token password: 'foo', grant_type: 'password'
        expect_api_error
      end

      describe 'valid parameters' do
        it 'requires valid username and password' do
          post_token username: 'foo', password: 'bar', grant_type: 'password'
          expect_api_error(:invalid_grant)
        end

        it 'returns a token with valid credentials' do
          user = create(:user)
          post_token username:   user.email,
                     password:   'password',
                     grant_type: 'password'

          expect_token
          expect(json_body['session']).to be
        end

        it 'allows settings a quicker expiration' do
          user = create(:user)
          post_token username:   user.email,
                     password:   'password',
                     grant_type: 'password',
                     expires_in: -10

          expires = Time.at(DateTime.current.to_i + json_body['expires_in'])
          expect(expires).to be < DateTime.current
        end
      end
    end

    describe '#refresh_token' do

      it 'requires a refresh_token parameter' do
        post_token grant_type: 'refresh_token'
        expect_api_error
      end

      it 'requires a valid refresh_token value' do
        post_token grant_type: 'refresh_token', refresh_token: 'foo'
        expect_api_error(:invalid_grant)
      end

      it 'returns a new token with a valid refresh token' do
        token = create(:api_token, client: @client)
        post_token grant_type: 'refresh_token', refresh_token: token.id
        expect_token
      end

    end

  end
end
