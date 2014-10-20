class AddEventToUserActivities < ActiveRecord::Migration
  def change
    add_column :user_activities, :event, :string
  end
end
