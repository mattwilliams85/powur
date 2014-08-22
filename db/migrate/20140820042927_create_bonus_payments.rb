class CreateBonusPayments < ActiveRecord::Migration
  def change
    create_table :pay_periods, id: false do |t|
      t.string :id, null: false
      t.string :type, null: false
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.datetime :calculated_at
    end
    execute 'alter table pay_periods add primary key (id);'

    create_table :rank_achievements do |t|
      t.references  :pay_period, null: false
      t.string :pay_period_id, null: false
      t.references  :user, null: false
      t.references  :rank, null: false

      t.foreign_key :pay_periods
      t.foreign_key :users
      t.foreign_key :ranks
    end
    add_index :rank_achievements, [ :pay_period_id, :user_id, :rank_id ], unique: true,
      name: 'idx_pay_period_user_rank'

  end
end
