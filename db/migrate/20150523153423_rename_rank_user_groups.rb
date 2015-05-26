class RenameRankUserGroups < ActiveRecord::Migration
  def change
    rename_table :rank_user_groups, :ranks_user_groups
  end
end
