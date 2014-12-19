class AddRememberMeFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :remember_created_at, :datetime
    add_column :users, :last_sign_in_at, :datetime
  end
end
