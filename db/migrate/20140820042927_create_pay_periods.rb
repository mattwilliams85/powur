class CreatePayPeriods < ActiveRecord::Migration
  def change
    create_table :pay_periods, id: false do |t|
      t.string :id, null: false
      t.string :type, null: false
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.datetime :calculated_at
    end
    execute 'alter table pay_periods add primary key (id);'

    create_table :order_totals do |t|
      t.string :pay_period_id, null: false
      t.references :user, null: false
      t.references :product, null: false
      t.integer :personal, null: false, default: 0
      t.integer :group, null: false
      t.integer :personal_lifetime, null: false, default: 0
      t.integer :group_lifetime, null: false

      t.foreign_key :pay_periods
      t.foreign_key :users
      t.foreign_key :products
    end
    add_index :order_totals, [ :pay_period_id, :user_id, :product_id ], unique: true,
      name: 'idx_order_totals_composite_key'

    create_table :rank_achievements do |t|
      t.string :pay_period_id, null: false
      t.references  :user, null: false
      t.references  :rank, null: false
      t.string :path, null: false

      t.foreign_key :pay_periods
      t.foreign_key :users
      t.foreign_key :ranks
    end
    add_index :rank_achievements, [ :pay_period_id, :user_id, :rank_id, :path ], unique: true,
      name: 'idx_rank_achievements_composite_key'

  end
end
