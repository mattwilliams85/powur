class AddPositionsToProducts < ActiveRecord::Migration
  def change
    add_column :products, :position, :integer
  end
end
