class AddStatusToPayPeriod < ActiveRecord::Migration
  def change
    add_column :pay_periods, :status, :integer, null: false, default: 0
    remove_column :pay_periods, :calculate_queued, :datetime
    remove_column :pay_periods, :calculate_started, :datetime
    remove_column :pay_periods, :distribute_queued, :datetime
    remove_column :pay_periods, :distribute_started, :datetime
  end
end
