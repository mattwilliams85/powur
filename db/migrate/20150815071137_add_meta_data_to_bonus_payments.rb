class AddMetaDataToBonusPayments < ActiveRecord::Migration
  def change
    add_column :bonus_payments, :bonus_data, :hstore, default: {}
  end
end
