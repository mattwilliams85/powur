class RemoveUniqueUserIndex < ActiveRecord::Migration
  def change
    remove_index :product_receipts, [ :user_id ]
  end
end
