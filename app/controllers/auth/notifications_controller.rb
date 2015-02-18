module Auth
  class NotificationsController < AuthController
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
  end
end
