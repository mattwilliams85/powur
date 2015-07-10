class AddSentAtToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :sender_id, :integer
    add_column :notifications, :sent_at, :datetime
    add_column :notifications, :finished_at, :datetime
    add_column :notifications, :recipient, :string
  end
end
