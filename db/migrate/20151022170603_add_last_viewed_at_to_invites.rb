class AddLastViewedAtToInvites < ActiveRecord::Migration
  def change
    add_column :customers, :last_viewed_at, :datetime
    add_column :invites, :last_viewed_at, :datetime
  end
end
