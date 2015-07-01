class AddImageOriginalPathToLibTopics < ActiveRecord::Migration
  def change
    add_column :resource_topics, :image_original_path, :string
  end
end
