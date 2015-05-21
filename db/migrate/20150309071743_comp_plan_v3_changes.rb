class CompPlanV3Changes < ActiveRecord::Migration
  def change
    drop_table :bonus_levels, {}

    create_table :bonus_amounts do |t|
      t.references :bonus, null: false, index: true
      t.integer :level, null: false, default: 0
      t.references :rank_path
      t.decimal :amounts, null: false, array: true, precision: 10, scale: 2, default: []

      t.foreign_key :bonuses, column: :bonus_id, primary_key: :id
      t.foreign_key :rank_paths
    end

    if column_exists?(:bonuses, :use_rank_at)
      remove_column :bonuses, :use_rank_at, :integer
      remove_column :bonuses, :achieved_rank_id, :integer
      remove_column :bonuses, :max_user_rank_id, :integer
      remove_column :bonuses, :min_upline_rank_id, :integer
    end

    add_column :bonuses, :product_id, :integer
    add_foreign_key :bonuses, :products
    change_column_default :bonuses, :type, 'Bonus'
  end

  def down
    drop_table :bonus_amounts, {}
    remove_column :bonuses, :product_id, :integer
  end
end
