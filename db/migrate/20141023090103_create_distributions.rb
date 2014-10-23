class CreateDistributions < ActiveRecord::Migration
  def change
    create_table :distributions do |t|
      t.string :pay_period_id, null: false
      t.references :user, null: false
      t.decimal :amount, null: false, precision: 10, scale: 2

      t.foreign_key :pay_periods
      t.foreign_key :users
    end
    add_index :distributions, [ :pay_period_id, :user_id ], unique: true
  end
end
