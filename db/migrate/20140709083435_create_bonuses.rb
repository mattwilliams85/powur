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
      t.hstore      :meta_data, default: ''
      t.boolean     :compress,  null: false, default: false
      t.decimal     :flat_amount, null: false, precision: 10, scale: 2, default: 0.0
      t.timestamps  null: false

      t.foreign_key :bonus_plans
    end
  end

end
