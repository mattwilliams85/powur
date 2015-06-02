class AddTosToUsers < ActiveRecord::Migration
  def change
    add_column :users, :tos, :string, limit: 5
    ActiveRecord::Base.connection.execute("UPDATE users SET tos = '1'")
  end
end
