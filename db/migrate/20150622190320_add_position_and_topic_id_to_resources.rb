class AddPositionAndTopicIdToResources < ActiveRecord::Migration
  def change
    add_column :resources, :position, :integer
    add_column :resources, :topic_id, :integer

    add_index :resources, [:position]
  end
end
