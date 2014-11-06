class ChangePayPeriodColumnFromDistributedAtToDisbursedAt < ActiveRecord::Migration
  def change
    rename_column :pay_periods, :distributed_at, :disbursed_at
  end
end
