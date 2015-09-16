class ChangeDefaultValueForAvailableInvites < ActiveRecord::Migration
  def change
    # Resets all new users to start with 0 invites
    change_column_default :users, :available_invites, 0

    # Removes all current users 5 more invites
    User.find_each(lifetime_rank: nil) do |user|
      user.update_column(:available_invites, 0)
    end
    puts 'Removes free invites from rank 0 advocates'
  end
end
