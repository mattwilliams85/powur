class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string  :name, null: false
      t.integer :bonus_volume, null: false
      t.integer :commission_percentage, default: 100, null: false
      t.boolean :distributor_only, null: false, default: false

      t.timestamps null: false
    end

    create_table :quote_fields do |t|
      t.references :product, null: false, index: true
      t.string :name, null: false
      t.integer :data_type, null: false, default: 1
      t.boolean :required, null: false, default: false

      t.foreign_key :products
    end

    create_table :quote_field_lookups do |t|
      t.references :quote_field, null: false, index: true
      t.string :value, null: false
      t.integer :identifier, null: false
      t.string :group

      t.foreign_key :quote_fields
    end
  end
end
