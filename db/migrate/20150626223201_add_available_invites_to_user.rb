class AddAvailableInvitesToUser < ActiveRecord::Migration
  def change
    add_column :users, :available_invites, :integer, default: 0
  end
end
