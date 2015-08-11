class AllowNullPayAsRank < ActiveRecord::Migration
  def up
    change_column :bonus_payments, :pay_as_rank, :integer, null: true
  end

  def down
    change_column :bonus_payments, :pay_as_rank, :integer, null: false
  end
end
