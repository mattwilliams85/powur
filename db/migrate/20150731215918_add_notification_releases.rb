class AddNotificationReleases < ActiveRecord::Migration
  def change
    create_table :notification_releases do |t|
      t.integer :user_id
      t.integer :notification_id
      t.string :recipient
      t.datetime :sent_at
      t.datetime :finished_at
      t.timestamps
    end

    remove_column :notifications, :sender_id
    remove_column :notifications, :sent_at
    remove_column :notifications, :finished_at
    remove_column :notifications, :recipient
    remove_column :notifications, :is_public
  end
end
