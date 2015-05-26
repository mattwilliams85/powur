class DefaultTotalsColumns < ActiveRecord::Migration
  def change
    change_column :order_totals, :group, :integer, default: 0
    change_column :order_totals, :group_lifetime, :integer, default: 0
  end
end
