module Api
  class TokenController < ApiController
    skip_before_action :authenticate!
    before_action :authenticate_client!

    # http://tools.ietf.org/html/rfc6749#section-4.3
    def ropc
      input = require_input(:username, :password)

      user = User.authenticate(input[:username], input[:password])
      api_error!(:invalid_grant, :password) unless user

      args = { user: user }
      if modify_expires?
        args[:expires_at] = DateTime.current + params[:expires_in].to_i
      end
      @token = @client.tokens.create!(args)

      render 'show'
    end

    # http://tools.ietf.org/html/rfc6749#section-6
    def refresh_token
      input = require_input(:refresh_token)

      token = ApiToken.find(input[:refresh_token])
      @token = token.refresh!

      render 'show'
    rescue ActiveRecord::RecordNotFound
      api_error!(:invalid_grant, :refresh_token)
    end

    def client_credentials
      @token = @client.tokens.valid.where(user_id: nil).first ||
        @client.tokens.create!

      render 'show', locals: { refresh: false }
    end

    def unsupported_grant_type
      api_error!(:unsupported_grant_type, grant_type: params[:grant_type])
    end

    def invalid_request
      api_error!(:invalid_request, :missing_params, params: 'grant_type')
    end

    private

    def authenticate_client!
      @client = authenticate_with_http_basic do |u, p|
        ApiClient.by_credentials(u, p).first
      end
      api_error!(:invalid_client) unless @client
    end

    def modify_expires?
      params[:expires_in] &&
        ApiToken::SECONDS_TILL_EXPIRATION > params[:expires_in].to_i
    end
  end
end
