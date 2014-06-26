class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string  :name, null: false
      t.decimal :commissionable_volume, precision: 8, scale: 2, null: false
      t.integer :commission_percentage, default: 100, null: false
      t.string  :quote_data, array: true, default: []

      t.timestamps
    end
  end
end
