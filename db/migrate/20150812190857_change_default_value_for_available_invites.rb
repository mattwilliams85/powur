class ChangeDefaultValueForAvailableInvites < ActiveRecord::Migration
  def change
    # Give all new users 5 invites to start
    change_column_default :users, :available_invites, 5

    # Give all current users 5 more invites
    User.all.each do |user|
      user.update_column(:available_invites, user.available_invites + 5)
    end
    puts "Gave all users 5 more invites"
  end
end
