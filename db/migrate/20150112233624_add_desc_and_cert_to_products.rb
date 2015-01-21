class AddDescAndCertToProducts < ActiveRecord::Migration
  def change
    add_column :products, :description, :text
    add_column :products, :certifiable, :boolean, default: false
    add_column :products, :image_original_path, :string

    add_index :products, [:certifiable]
  end
end
