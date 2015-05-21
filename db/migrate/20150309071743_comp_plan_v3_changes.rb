class CompPlanV3Changes < ActiveRecord::Migration
  def change
    create_table :bonus_amounts do |t|
      t.references :bonus, null: false, index: true
      t.integer :level, null: false, default: 0
      t.references :rank_path
      t.decimal :amounts, null: false, array: true, precision: 10, scale: 2, default: []

      t.foreign_key :bonuses, column: :bonus_id, primary_key: :id
      t.foreign_key :rank_paths
    end

    add_column :bonuses, :product_id, :integer
    add_foreign_key :bonuses, :products
    change_column_default :bonuses, :type, 'Bonus'
  end
end
