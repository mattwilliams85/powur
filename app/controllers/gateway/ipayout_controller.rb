module Gateway
  class IpayoutController < GatewayController
    @notification_map = { 'AccCREATED' => 'new account',
                          'AccNOC'     => 'status change' }
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

    def notify_merchant
      @notification_type = nil
      @notification_status = nil
      @notification_message = nil
      if params['act'].empty? || params['user'].empty?
        @notification_status = 0

      else
        @notification_type = @notification_map[params['act']]
        user = User.find_by_email(params['user'])
        case params['act']
        when "AccCREATED"
          #handle Account created notification
          @notification_message = user + " created an account."
        when "AccNOC"
          #handle Account created notification
          if params['status'].empty?
            break
          end

          @notification_status = params['status']
          @notification_message = user + " account status has changed to " + status + "."

        end
        puts @notification_message

      end

      render json: @verify_user
    end

    def validate_user_credentials?(params)
      User.authenticate(params['UserName'], params['Password'])
    end
  end
end
