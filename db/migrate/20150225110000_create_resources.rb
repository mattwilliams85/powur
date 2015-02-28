class CreateResources < ActiveRecord::Migration
  def change
    create_table :resources do |t|
      t.integer :user_id
      t.string :title
      t.text :description
      t.string :file_original_path
      t.string :file_type, limit: 60
      t.string :thumbnail_path
      t.boolean :is_public
      t.timestamps
    end

    add_index :resources, [:file_type, :is_public]
  end
end
