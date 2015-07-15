class AddTimestampsToProductReceipts < ActiveRecord::Migration
  def change
    add_column :product_receipts, :created_at, :datetime
    add_column :product_receipts, :updated_at, :datetime
  end
end
