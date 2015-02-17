module Auth
  class NotificationsController < AuthController
    def index
      respond_to do |format|
        format.html
        format.json do
          @notifications = Notification.all.order(id: :desc)
        end
      end
    end
  end
end
