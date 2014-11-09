module Api
  class TokenController < ApiController
    skip_before_action :authenticate!
    before_action :authenticate_client!

    # http://tools.ietf.org/html/rfc6749#section-4.3
    def ropc
      input = expect_params(:username, :password)

      user = User.authenticate(input[:username], input[:password])
      error!(:invalid_grant, 'invalid username and/or password') unless user

      args = { user: user }
      if modify_expires?
        args[:expires_at] = DateTime.current + params[:expires_in].to_i
      end
      @token = @client.tokens.create!(args)

      render 'show'
    end

    # http://tools.ietf.org/html/rfc6749#section-6
    def refresh_token
      input = expect_params(:refresh_token)

      token = ApiToken.find(input[:refresh_token])
      @token = token.refresh!

      render 'show'
    rescue ActiveRecord::RecordNotFound
      error!(:invalid_grant, 'invalid refresh_token')
    end

    def unsupported_grant_type
      error!(:unsupported_grant_type,
             "invalid grant_type value of: \"#{params[:grant_type]}\"")
    end

    def invalid_request
      error!(:invalid_request, "missing \"grant_type\" parameter")
    end

    private

    def authenticate_client!
      @client = authenticate_with_http_basic do |u, p|
        ApiClient.by_credentials(u, p)
      end
      error!(:invalid_client, 'invalid client credentials') unless @client
    end

    def modify_expires?
      params[:expires_in] &&
        ApiToken::SECONDS_TILL_EXPIRATION > params[:expires_in].to_i
    end
  end
end
