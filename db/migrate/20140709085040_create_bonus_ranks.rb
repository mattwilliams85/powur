class CreateBonusRanks < ActiveRecord::Migration
  def change
    create_table :bonus_ranks, id: false do |t|
      t.belongs_to :bonus, null: false
      t.belongs_to :rank, null: false
      t.integer :amounts

      t.foreign_key :bonuses, column: :bonus_id, primary_key: :id
      t.foreign_key :ranks, column: :rank_id, primary_key: :id
    end

    execute 'alter table bonus_ranks add primary key (bonus_id, rank_id);'
  end
end
