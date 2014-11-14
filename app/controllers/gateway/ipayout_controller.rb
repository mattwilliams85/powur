module Gateway
  class IpayoutController < GatewayController

    def verify_user
      if params['UserName'].empty? || params['Password'].empty?
        verify_user = 0
      else
        validate_user_credentials?(params)
        verify_user = 1
      end
      @verify_user = verify_user

      render json: @verify_user
    end

    def validate_user_credentials?(params)
      user = User.authenticate(params['UserName'], params['Password'])
    end
  end
end
