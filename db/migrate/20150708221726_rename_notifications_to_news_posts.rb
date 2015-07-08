class RenameNotificationsToNewsPosts < ActiveRecord::Migration
  def change
    rename_table :notifications, :news_posts
  end
end
