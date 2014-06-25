require 'spec_helper'

describe User do

  describe '@authenticate' do
    let(:password) { 'password123' }

    before :each do
      @user = create(:user, password: password)
    end

    it 'returns the user with valid credentials' do
      expect(User.authenticate(@user.email, password)).to_not be_nil
    end

    it 'does not return the user with an invalid password' do
      expect(User.authenticate(@user.email, 'nope')).to be_nil
    end

    it 'changes the password' do
      newpass = 'mynewpassword'
      @user.password = newpass
      @user.save!

      expect(User.authenticate(@user.email, newpass)).to_not be_nil
    end
  end

  describe '#remaining_invites' do
    it 'returns the correct number of remaining invites' do
      user = create(:user)
      create_list(:invite, 3, sponsor: user)

      expect(user.remaining_invites).to eq(2)
    end
  end

  describe 'contact field' do
    it 'allows properties to be set directly on the model' do
      user = create(:user, phone: '8585551212')

    end
  end

  describe '#upline' do

    before :all do
      @root = create(:user)
      @parent = create(:user, sponsor: @root)
      @child = create(:user, sponsor: @parent)
    end

    it 'sets the upline users after create' do
      expect(@root.upline).to eq([@root.id])
      expect(@parent.upline).to eq([@root.id, @parent.id])
      expect(@child.upline).to eq([@root.id, @parent.id, @child.id])
    end

    it 'returns the upline users' do
      users = @child.upline_users
      expect(users.pluck(:id).sort).to eq([@root.id, @parent.id].sort)
    end

    it 'returns the downline users' do
      users = @root.downline_users
      expect(users.pluck(:id).sort).to eq([@parent.id, @child.id].sort)
    end

    it 'returns the downline users by level' do
      root = create(:user)
      parents = create_list(:user, 2, sponsor: root)
      childs = parents.map do |parent|
        create_list(:user, 2, sponsor: parent)
      end.flatten

      users = root.downline_users(1)
      expect(users.pluck(:id).sort).to eq(parents.map(&:id).sort)

      users = root.downline_users(2)
      expect(users.pluck(:id).sort).to eq(childs.map(&:id).sort)
    end

    after :all do
      User.all.destroy
    end

  end

end