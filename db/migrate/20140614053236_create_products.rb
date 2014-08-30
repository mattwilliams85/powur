class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string  :name, null: false
      t.integer :bonus_volume, null: false
      t.integer :commission_percentage, default: 100, null: false
      t.string  :quote_data, array: true, default: []
      t.boolean :distributor_only, null: false, default: false

      t.timestamps null: false
    end
  end
end
