class AddRefundedAtToReceipts < ActiveRecord::Migration
  def change
    add_column :product_receipts, :refunded_at, :datetime
  end
end
