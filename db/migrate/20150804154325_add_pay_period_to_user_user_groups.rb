class AddPayPeriodToUserUserGroups < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        drop_table :user_user_groups

        create_table :user_user_groups, id: false do |t|
          t.references :user, null: false
          t.string :user_group_id, null: false
          t.references :pay_period, type: :string

          t.foreign_key :users, column: :user_id, primary_key: :id
          t.foreign_key :user_groups, column: :user_group_id, primary_key: :id
          t.foreign_key :pay_periods, column: :pay_period_id, primary_key: :id
        end

        add_index :user_user_groups,
                  [ :user_id, :user_group_id, :pay_period_id ],
                  unique: true,
                  where:  'pay_period_id is not null',
                  name:   'idx_user_user_groups_not_null_pp'
        add_index :user_user_groups,
                  [ :user_id, :user_group_id ],
                  unique: true,
                  where:  'pay_period_id is null',
                  name:   'idx_user_user_groups_null_pp'
      end
    end

    reversible do |dir|
      dir.down do
        drop_table :user_user_groups

        create_table :user_user_groups, id: false do |t|
          t.references :user, null: false
          t.string :user_group_id, null: false

          t.foreign_key :users, column: :user_id, primary_key: :id
          t.foreign_key :user_groups, column: :user_group_id, primary_key: :id
        end
        execute 'alter table user_user_groups add primary key (user_id, user_group_id);'
      end
    end
  end
end
