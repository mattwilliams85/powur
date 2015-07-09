module Admin
  class NotificationsController < AdminController
    page
    sort id_desc: { id: :desc },
         id_asc:  { id: :asc }

    before_filter :fetch_notification, only: [:show, :update, :destroy ]

    def index
      @notifications = apply_list_query_options(Notification)
      render :index
    end

    def create
      @notification = Notification.new(input)
      @notification.user_id = current_user.id
      @notification.save!
      index
    end

    def destroy
      @notification.destroy!
      head :ok
    end

    def show
    end

    def update
      @notification.update_attributes!(input)
      index
    end

    private

    def fetch_notification
      @notification = Notification.find(params[:id])
    end

    def input
      allow_input(:content)
    end
  end
end
