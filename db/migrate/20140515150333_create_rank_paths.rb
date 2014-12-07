class CreateRankPaths < ActiveRecord::Migration
  def change
    create_table :rank_paths do |t|
      t.string :name, null: false
      t.string :description
      t.integer :precedence, null: false, default: 1
    end
    add_index :rank_paths, [ :precedence ], unique: true
  end
end
