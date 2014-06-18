class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.decimal :business_volume, precision: 8, scale: 2
      t.string :quote_data, array: true, default: []

      t.timestamps
    end
  end
end
