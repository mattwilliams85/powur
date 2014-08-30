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
      t.references  :achieved_rank
      t.integer     :schedule,  null: false, default: 2  # [ :weekly, :pay_period ]
      t.references  :max_user_rank
      t.references  :min_upline_rank
      t.boolean     :compress,  null: false, default: false
      t.integer     :flat_amount, null: false, default: 0
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

    create_table :bonus_levels, id: false do |t|
      t.references :bonus, null: false
      t.integer :level, null: false, default: 0
      t.decimal :amounts, null: false, array: true, precision: 5, scale: 5, default: []

      t.foreign_key :bonuses, column: :bonus_id, primary_key: :id
    end
    execute 'alter table bonus_levels add primary key (bonus_id, level);'

  end

end
