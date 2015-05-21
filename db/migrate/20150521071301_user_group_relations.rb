class UserGroupRelations < ActiveRecord::Migration
  def change
    create_table :rank_user_groups, id: false do |t|
      t.references :rank, null: false
      t.string :user_group_id, null: false

      t.foreign_key :ranks
      t.foreign_key :user_groups
    end
  end
end
