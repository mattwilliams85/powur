class CreateQualifications < ActiveRecord::Migration
  def change
    create_table :qualifications do |t|
      t.string  :type, null: false
      t.string  :path, null: false, default: 'default'
      t.integer :period, null: false
      t.integer :quantity, null: false, default: 1
      t.integer :max_leg_percent

      t.belongs_to :rank, index: true
      t.belongs_to :product, index: true, null: false

      t.foreign_key :ranks, column: :rank_id, primary_key: :id
      t.foreign_key :products, column: :product_id, primary_key: :id
    end
  end
end


# - certification/test flag
# - n lifetime sales
# - n pay period group sales, max leg % 
