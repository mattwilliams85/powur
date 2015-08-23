class RenamePayPeriodsDisbursedAt < ActiveRecord::Migration
  def change
    rename_column :pay_periods, :disbursed_at, :distributed_at
  end
end
