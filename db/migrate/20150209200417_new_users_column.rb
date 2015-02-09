class NewUsersColumn < ActiveRecord::Migration
  def change
    add_column :users, :moved, :boolean
  end
end
