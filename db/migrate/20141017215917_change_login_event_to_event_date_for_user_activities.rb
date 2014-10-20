class ChangeLoginEventToEventDateForUserActivities < ActiveRecord::Migration
  def change
    rename_column :user_activities, :login_event, :event_time
  end
end
