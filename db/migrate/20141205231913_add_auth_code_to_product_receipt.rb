class AddAuthCodeToProductReceipt < ActiveRecord::Migration
  def change
    add_column :product_receipts, :auth_code, :string
  end
end
