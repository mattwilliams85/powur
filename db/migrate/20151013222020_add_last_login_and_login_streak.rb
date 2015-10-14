class AddLastLoginAndLoginStreak < ActiveRecord::Migration
  def change
    add_column :users, :login_streak, :integer, default: 0, null: false
  end
end
