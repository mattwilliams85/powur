class AddIsPublicToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :is_public, :boolean
    add_index :notifications, [:is_public]
  end
end
