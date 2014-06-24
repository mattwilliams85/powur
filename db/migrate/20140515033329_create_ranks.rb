class CreateRanks < ActiveRecord::Migration
  def change
    create_table :ranks, id: false do |t|
      t.integer :id, null: false
      t.string :title, null: false
    end
    execute 'alter table ranks add primary key (id);'
  end
end
