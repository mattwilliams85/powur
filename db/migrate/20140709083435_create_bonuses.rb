class CreateBonuses < ActiveRecord::Migration

  def change
    create_table :bonus_plans do |t|
      t.string    :name, null: false
      t.integer   :start_year
      t.integer   :start_month
    end
    add_index :bonus_plans, [ :start_year, :start_month ], unique: true

    create_table :bonuses do |t|
      t.references  :bonus_plan, null: false
      t.string      :type, null: false
      t.string      :name, null: false
      t.integer     :schedule, null: false, default: 2      # [ :weekly, :monthly ]
      t.integer     :use_rank_at, null: false, default: 2   # [ :sale, :pay_period_end ]
      t.references  :achieved_rank
      t.references  :max_user_rank
      t.references  :min_upline_rank
      t.boolean     :compress,  null: false, default: false
      t.decimal     :flat_amount, null: false, precision: 10, scale: 2, default: 0.0
      t.timestamps  null: false

      t.foreign_key :bonus_plans
      t.foreign_key :ranks, column: :achieved_rank_id, primary_key: :id
      t.foreign_key :ranks, column: :max_user_rank_id, primary_key: :id
      t.foreign_key :ranks, column: :min_upline_rank_id, primary_key: :id
    end

    create_table :bonus_sales_requirements, id: false do |t|
      t.references  :bonus,     null: false
      t.references  :product,   null: false
      t.integer     :quantity,  null: false, default: 1
      t.boolean     :source,    null: false, default: true

      t.foreign_key :bonuses, column: :bonus_id, primary_key: :id
      t.foreign_key :products, column: :product_id, primary_key: :id
    end
    execute 'alter table bonus_sales_requirements add primary key (bonus_id, product_id);'

    create_table :bonus_levels do |t|
      t.references :bonus, null: false, index: true
      t.integer :level, null: false, default: 0
      t.references :rank_path, null: false
      t.decimal :amounts, null: false, array: true, precision: 5, scale: 5, default: []
      t.references :rank_path

      t.foreign_key :bonuses, column: :bonus_id, primary_key: :id
      t.foreign_key :rank_paths
    end
    add_index :bonus_levels,
              [ :bonus_id, :level, :rank_path_id ],
              unique: true,
              where:  'rank_path_id is not null',
              name:   'bonus_levels_comp_key_with_rp'
    add_index :bonus_levels,
              [ :bonus_id, :level, :rank_path_id ],
              unique: true,
              where:  'rank_path_id is null',
              name:   'bonus_levels_comp_key_without_rp'
  end

end
