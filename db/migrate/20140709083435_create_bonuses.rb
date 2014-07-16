class CreateBonuses < ActiveRecord::Migration
  def change
    create_table :sales_bonuses do |t|
      t.string      :name,          null: false
      t.integer     :schedule,      null: false, default: 2  # [ :weekly, :pay_period ]
      t.integer     :pays,          null: false, default: 1      # [ :distributor, :upline ]
      t.boolean     :compress,      null: false, default: false
      t.boolean     :levels,        null: false, default: false
      t.integer     :amount,        array: true

      t.belongs_to  :product, index: true
      t.belongs_to  :min_distributor_rank, foreign_key: :min_distributor_rank, class_name: 'Rank'
      t.belongs_to  :max_upline_rank, foreign_key: :max_upline_rank, class_name: 'Rank'

      t.foreign_key :products, column: :product_id, primary_key: :id
      t.foreign_key :ranks, column: :min_distributor_rank, primary_key: :id
      t.foreign_key :ranks, column: :max_upline_rank, primary_key: :id
    end
  end
end
