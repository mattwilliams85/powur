class AddUtilitiesToUser < ActiveRecord::Migration
  def change
    add_column :users, :utilities, :hstore
  end
end
