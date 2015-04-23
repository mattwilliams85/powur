class AddImageOriginalPathToUsers < ActiveRecord::Migration
  def change
    add_column :users, :image_original_path, :string
  end
end
