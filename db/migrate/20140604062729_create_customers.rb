class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.string  :url_slug, null: false
      t.integer :status, default: 0
      t.string  :first_name, null: false
      t.string  :last_name, null: false
      t.string  :email
      t.string  :phone
      t.string  :address
      t.string  :city
      t.string  :state
      t.string  :zip
      t.string  :utility
      t.integer :rate_schedule
      t.integer :kwh
      t.string  :roof_material
      t.integer :roof_age
      t.timestamps null: false

      t.belongs_to :promoter, index: true, null: false

      t.foreign_key :users, column: :promoter_id, primary_key: :id
    end
    add_index :customers, [ :url_slug ], unique: true
  end
end
