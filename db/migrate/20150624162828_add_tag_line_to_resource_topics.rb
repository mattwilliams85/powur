class AddTagLineToResourceTopics < ActiveRecord::Migration
  def change
    add_column :resources, :tag_line, :string
  end
end
