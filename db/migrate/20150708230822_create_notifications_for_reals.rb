class CreateNotificationsForReals < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :user_id
      t.string :content
      t.timestamps
    end
  end
end
