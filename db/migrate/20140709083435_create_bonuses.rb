class CreateBonuses < ActiveRecord::Migration
  def change
    create_table :bonuses do |t|
      t.string      :type, null: false
      t.integer     :schedule, null: false
      t.integer     :rank_amounts, array: true
      t.hstore      :data
      t.belongs_to  :product, index: true

      t.foreign_key :products, column: :product_id, primary_key: :id
    end
  end
end
