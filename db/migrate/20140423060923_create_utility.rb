class CreateUtility < ActiveRecord::Migration
  def change
    create_table :utilities, id: false do |t|
      t.integer :id, null: false
      t.string :name, null: false
    end
    execute 'alter table utilities add primary key (id);'
  end
end
