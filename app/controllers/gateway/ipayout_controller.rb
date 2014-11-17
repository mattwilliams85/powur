module Gateway
  class IpayoutController < GatewayController
    @notification_map = { 'AccCREATED' => 'new account',
                          'AccNOC'     => 'status change' }
    def verify_user
      @verify_user = 0
      if !params['UserName'].present? || !params['Password'].present?
        @verify_user = 0
      else
        if validate_user_credentials?(params)
          @verify_user = 1
        end
      end

      render json: @verify_user
    end

    def validate_user_credentials?(params)
      User.authenticate(params['UserName'], params['Password'])
    end
  end
end
