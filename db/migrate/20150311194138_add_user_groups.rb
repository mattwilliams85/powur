class AddUserGroups < ActiveRecord::Migration
  def change
    create_table :user_groups, id: false do |t|
      t.string :id, null: false
      t.string :title, null: false
      t.string :description
    end
    execute 'alter table user_groups add primary key (id);'

    create_table :user_user_groups, id: false do |t|
      t.references :user, null: false
      t.string :user_group_id, null: false

      t.foreign_key :users, column: :user_id, primary_key: :id
      t.foreign_key :user_groups, column: :user_group_id, primary_key: :id
    end
    execute 'alter table user_user_groups add primary key (user_id, user_group_id);'

    create_table :user_group_requirements do |t|
      t.string :user_group_id, null: false
      t.references :product, null: false
      t.integer :event_type, null: false
      t.integer :quantity, null: false, default: 1

      t.foreign_key :products, column: :product_id, primary_key: :id
      t.foreign_key :user_groups, column: :user_group_id, primary_key: :id
    end
  end
end
