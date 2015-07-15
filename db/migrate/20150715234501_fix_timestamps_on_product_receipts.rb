class FixTimestampsOnProductReceipts < ActiveRecord::Migration
  def change
    remove_column :product_receipts, :created_at, :datetime
    remove_column :product_receipts, :updated_at, :datetime

    add_timestamps :product_receipts
  end
end