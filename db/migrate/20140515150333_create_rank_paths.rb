class CreateRankPaths < ActiveRecord::Migration
  def change
    create_table :rank_paths do |t|
      t.string :name, null: false
      t.string :description
      t.boolean :default, null: false, default: false
    end
  end
end
