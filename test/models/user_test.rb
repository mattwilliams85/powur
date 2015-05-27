require 'test_helper'
 
class UserTest < ActiveSupport::TestCase
  def setup
    @user = users(:advocate) 
  end

  it 'authenticates' do
    result = User.authenticate(@user.email, default_password)
    result.must_equal @user
  end

  it 'does not return the user with an invalid password' do
    result = User.authenticate(@user.email, "#{default_password}x")
    result.must_be_nil
  end

  it 'changes the password' do
    newpass = 'mynewpassword'
    @user.password = newpass
    @user.save!

    result = User.authenticate(@user.email, newpass)
    result.must_equal @user
  end

  it 'returns the correct number of remaining invites' do
    invite = invites(:george)
    expected = SystemSettings.max_invites - 1
    invite.sponsor.remaining_invites.must_equal expected
  end
end
