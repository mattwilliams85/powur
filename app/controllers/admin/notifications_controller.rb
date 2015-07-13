module Admin
  class NotificationsController < AdminController
    page
    sort id_desc: { id: :desc },
         id_asc:  { id: :asc }

    before_filter :fetch_notification,
                  only: [:show, :update, :destroy, :send_out ]

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

    def send_out
      params.require(:recipient)
      @notification.update_attributes!(
        sender_id: current_user.id,
        sent_at:   Time.zone.now,
        recipient: params[:recipient])
      @notification.delay.send_out

      head :ok
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
