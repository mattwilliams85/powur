module Auth
  class NotificationsController < AuthController
    def index
      respond_to do |format|
        format.html
        format.json do
          @notifications = Notification.all
        end
      end
    end
  end
end