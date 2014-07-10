class CreateBonuses < ActiveRecord::Migration
  def change
    create_table :bonuses do |t|
      t.integer :type, null: false
      t.integer :amount, array: true
      t.hstore  :generational_amounts, default: ''
      t.belongs_to :product, index: true, null: false

      t.foreign_key :products, column: :product_id, primary_key: :id
    end
  end
end
