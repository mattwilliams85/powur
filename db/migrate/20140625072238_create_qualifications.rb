class CreateQualifications < ActiveRecord::Migration
  def change
    create_table :qualifications do |t|
      t.string  :type, null: false
      t.integer :time_period, null: false
      t.integer :quantity, null: false, default: 1
      t.integer :max_leg_percent

      t.references :rank, index: true
      t.references :product, index: true, null: false
      t.references :rank_path, null: false

      t.foreign_key :ranks
      t.foreign_key :products
      t.foreign_key :rank_paths
    end
  end
end


# - certification/test flag
# - n lifetime sales
# - n pay period group sales, max leg % 
