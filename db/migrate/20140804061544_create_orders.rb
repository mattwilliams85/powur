class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.references  :product,   null: false
      t.references  :user,      null: false
      t.references  :customer,  null: false
      t.references  :quote
      t.integer     :quantity, null: :false, default: 1
      t.datetime    :order_date, null: false
      t.integer     :status, null: false, default: 1
      t.timestamps  null: false

      t.foreign_key :products
      t.foreign_key :users
      t.foreign_key :customers
      t.foreign_key :quotes
    end
    add_index :orders, [ :quote_id ], unique: true
  end
end
