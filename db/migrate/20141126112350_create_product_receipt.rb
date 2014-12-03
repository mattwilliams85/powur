class CreateProductReceipt < ActiveRecord::Migration
  def change

    create_table :product_receipts do |t|
      t.references  :product,        null: false
      t.references  :user,           null: false
      t.decimal     :amount,         null: false, precision: 10, scale: 2
      t.string      :transaction_id, null: false
      t.string      :order_id,       null: false
      t.foreign_key :products
      t.foreign_key :users
    end
    add_index :product_receipts, [ :user_id ], unique: true
  end
end
