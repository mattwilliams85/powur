class CreateProductInvites < ActiveRecord::Migration
  def change
    create_table :product_invites do |t|
      t.integer :product_id
      t.integer :customer_id
      t.integer :user_id
      t.integer :status, null: false, default: 0
      t.timestamps null: false
    end

    add_index :product_invites, [ :status ]
  end
end
