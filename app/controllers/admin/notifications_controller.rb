module Admin
  class NotificationsController < AdminController
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
