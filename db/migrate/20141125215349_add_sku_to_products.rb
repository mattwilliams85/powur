class AddSkuToProducts < ActiveRecord::Migration
  def change
    add_column :products, :sku, :string
  end
end
