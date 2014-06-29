class CreateQualifications < ActiveRecord::Migration
  def change
    create_table :qualifications do |t|
      t.string  :path, null: false
      t.string  :type, null: false
      t.integer :period
      t.integer :quantity
      t.integer :max_leg_percent

      t.belongs_to :rank, index: true, null: false
      t.belongs_to :certification, index: true
      t.belongs_to :product, index: true

      t.foreign_key :ranks, column: :rank_id, primary_key: :id
      t.foreign_key :certifications, column: :certification_id, primary_key: :id
      t.foreign_key :products, column: :product_id, primary_key: :id
    end
  end
end


# - certification/test flag
# - n lifetime sales
# - n pay period group sales, max leg % 
