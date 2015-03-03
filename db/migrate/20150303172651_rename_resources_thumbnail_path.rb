class RenameResourcesThumbnailPath < ActiveRecord::Migration
  def change
    rename_column :resources, :thumbnail_path, :image_original_path
  end
end
