class AddPurchasedAtToReceipts < ActiveRecord::Migration
  def change
    add_column :product_receipts, :purchased_at, :datetime

    ProductReceipt.all.each { |r| r.update_column(:purchased_at, r.updated_at) }
  end
end
