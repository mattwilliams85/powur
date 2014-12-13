class RemoveUtilitiesFromUser < ActiveRecord::Migration
  def change
    remove_column :users, :utilities
  end
end
