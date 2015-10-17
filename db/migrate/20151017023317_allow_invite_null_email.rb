class AllowInviteNullEmail < ActiveRecord::Migration
  def up
    change_column :invites, :email, :string, null: true
  end

  def down
    change_column :invites, :email, :string, null: false
  end
end
