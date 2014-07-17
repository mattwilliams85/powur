class CreateBonuses < ActiveRecord::Migration

  def change
    create_table :bonuses do |t|
      t.string    :name,      null: false
      t.integer   :schedule,  null: false, default: 2  # [ :weekly, :pay_period ]
      t.integer   :pays,      null: false, default: 1  # [ :distributor, :upline ]
      t.boolean   :compress,  null: false, default: false
      t.boolean   :levels,    null: false, default: false
      t.integer   :amount,    array: true
      t.references   :max_user_rank
      t.references   :min_upline_rank

      t.foreign_key :ranks, column: :max_user_rank_id, primary_key: :id
      t.foreign_key :ranks, column: :min_upline_rank_id, primary_key: :id
    end

    create_table :bonus_sales_requirements do |t|
      t.belongs_to  :bonus,     null: false
      t.integer     :quantity,  null: false, default: 1
      t.boolean     :source,    null: false, default: true

      t.foreign_key :bonuses, column: :bonus_id, primary_key: :id
    end

  end

end
