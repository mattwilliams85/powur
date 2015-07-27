require 'test_helper'
 
class UserTest < ActiveSupport::TestCase
  def setup
    @user = users(:advocate)
  end

  def test_authenticate
    result = User.authenticate(@user.email, default_password)
    result.must_equal @user
  end

  def test_authenticate_bad_password
    result = User.authenticate(@user.email, "#{default_password}x")
    result.must_be_nil
  end

  def test_change_password
    newpass = 'mynewpassword'
    @user.password = newpass
    @user.save!

    result = User.authenticate(@user.email, newpass)
    result.must_equal @user
  end

  def test_move
    child = users(:child)
    parent = users(:child2)
    User.move_user(child, parent)

    child.ancestor?(parent.id).must_equal true
    users(:grandchild).ancestor?(parent.id).must_equal true
    child.parent_id.must_equal parent.id
  end

  def test_moving_to_ineligible_parent
    -> { User.move_user(users(:child), users(:grandchild)) }
      .must_raise ArgumentError
  end
end
