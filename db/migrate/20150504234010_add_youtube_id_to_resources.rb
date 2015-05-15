class AddYoutubeIdToResources < ActiveRecord::Migration
  def change
    add_column :resources, :youtube_id, :string
  end
end
