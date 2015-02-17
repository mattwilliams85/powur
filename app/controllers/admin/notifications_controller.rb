module Admin
  class NotificationsController < AdminController
    def index
      respond_to do |format|
        format.html
        format.json do
          @notifications = Notification.all.reverse_order
        end
      end
    end

    def create
      @notification = Notification.create(input)
      render 'index'
    end

    private

    def input
      allow_input(:content)
    end
  end
end
