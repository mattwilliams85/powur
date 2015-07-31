module Admin
  class NotificationsController < AdminController
    page
    sort id_desc: { id: :desc },
         id_asc:  { id: :asc }

    before_filter :fetch_notification,
                  only: [ :show, :update, :destroy, :send_out ]

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
      params.require(:recipients)
      recipients = params[:recipients].split(',')
      recipients.each do |recipient|
        release = @notification.releases.create!(
          user_id:   current_user.id,
          sent_at:   Time.zone.now,
          recipient: recipient)
        release.delay.send_out
      end

      render :show
    end

    private

    def fetch_notification
      @notification = Notification.find(params[:id].to_i)
    end

    def input
      allow_input(:content, :is_public)
    end
  end
end
