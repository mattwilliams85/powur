module Admin
  class NotificationsController < AdminController
    page max_limit: 3
    sort id:  { id: :desc }

    def index
      respond_to do |format|
        format.html
        format.json do
          @notifications = apply_list_query_options(Notification)
        end
      end
    end

    def create
      @notification = Notification.create(input)
      render 'index'
    end

    def destroy
      @notification = Notification.find(params[:id])

      @notification.destroy!
      @notifications = Notification.all.order(id: :desc)

      render 'index'
    end

    private

    def input
      allow_input(:content)
    end
  end
end
