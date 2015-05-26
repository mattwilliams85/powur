class NullableProductBonusVolume < ActiveRecord::Migration
  def change
    change_column :products, :bonus_volume, :integer, null: true
  end
end
