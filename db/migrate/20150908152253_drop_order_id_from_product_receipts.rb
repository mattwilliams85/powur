class DropOrderIdFromProductReceipts < ActiveRecord::Migration
  def change
    remove_column :product_receipts, :order_id, :string
  end
end
