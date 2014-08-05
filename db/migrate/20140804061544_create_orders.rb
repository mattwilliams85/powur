class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.references  :bonus_plan, null: false
      t.references  :product, null: false
      t.references  :user, null: false
      t.integer     :quantity, null: :false, default: 1
      t.references  :quote
      t.datetime    :order_date, null: false
      t.integer     :status, null: false, default: 1

      t.timestamps  null: false

      t.foreign_key :bonus_plans
      t.foreign_key :products
      t.foreign_key :users
      t.foreign_key :quotes
    end
  end
end
