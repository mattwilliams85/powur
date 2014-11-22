class CreateRankPaths < ActiveRecord::Migration
  def change
    create_table :rank_paths do |t|
      t.string :name, null: false
    end
  end
end
