class UpdateProductReceiptsAmount < ActiveRecord::Migration
  def change
    change_column :product_receipts, :amount, :float, null: false
    ActiveRecord::Base.connection.execute(
      'UPDATE product_receipts SET amount = amount / 100')

    change_column :products, :bonus_volume, :float
    ActiveRecord::Base.connection.execute(
      'UPDATE products SET bonus_volume = bonus_volume / 100')
  end
end
