class CompPlanV3Changes < ActiveRecord::Migration
  def change
    drop_table :bonus_levels
    drop_table :bonus_sales_requirements

    create_table :bonus_amounts do |t|
      t.references :bonus, null: false, index: true
      t.integer :level, null: false, default: 0
      t.references :rank_path, null: false
      t.decimal :amounts, null: false, array: true, precision: 5, scale: 2, default: []

      t.foreign_key :bonuses, column: :bonus_id, primary_key: :id
      t.foreign_key :rank_paths
    end

    remove_column :bonuses, :use_rank_at
    remove_column :bonuses, :achieved_rank_id
    remove_column :bonuses, :max_user_rank_id
    remove_column :bonuses, :min_upline_rank_id

    add_column :bonuses, :product_id, :integer
    add_foreign_key :bonuses, :products
  end
end
