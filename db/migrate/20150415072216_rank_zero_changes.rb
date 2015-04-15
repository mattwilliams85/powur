class RankZeroChanges < ActiveRecord::Migration
  def change
    change_column :bonus_payments, :pay_as_rank, :integer, default: 0, null: false
    change_column :rank_achievements, :rank_path_id, :integer, null: true
  end
end
