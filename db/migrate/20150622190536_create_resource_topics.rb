class CreateResourceTopics < ActiveRecord::Migration
  def change
    create_table :resource_topics do |t|
      t.string :title
      t.integer :position
      t.timestamps
    end
  end
end
