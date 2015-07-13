require 'spec_helper'

describe User, type: :model do

  describe '@authenticate' do
    let(:password) { 'password123' }

    before :each do
      @user = create(:user, password: password, password_confirmation: password)
    end

    it 'returns the user with valid credentials' do
      expect(User.authenticate(@user.email, password)).to_not be_nil
    end

    it 'does not return the user with an invalid password' do
      expect(User.authenticate(@user.email, 'wrong')).to be_nil
    end

    it 'changes the password' do
      newpass = 'mynewpassword'
      @user.password = newpass
      @user.save!

      expect(User.authenticate(@user.email, newpass)).to_not be_nil
    end
  end

  describe '#available_invites' do
    it 'returns the correct number of available invites' do
      user = create(:user, available_invites: 10)
      create_list(:invite, 3, sponsor: user)

      expect(user.available_invites).to eq(7)
    end
  end

  describe '#create' do
    let(:user_params) { {} }
    let(:user) { create(:user, user_params) }

    it 'destroys the invite used to create the user' do
      expect(Invite.find_by(email: "#{user.email}")).to be_nil
    end
  end

  describe '#upline' do

    before :each do
      @root = create(:user)
      @parent = create(:user, sponsor: @root)
      @children = create_list(:user, 2, sponsor: @parent)
    end

    it 'sets the upline users after create' do
      expect(@root.upline).to eq([ @root.id ])
      expect(@parent.upline).to eq([ @root.id, @parent.id ])
      expect(@children.first.upline)
        .to eq([ @root.id, @parent.id, @children.first.id ])
    end

    it 'returns the upline users' do
      users = @children.first.upline_users
      expect(users.pluck(:id).sort).to eq([@root.id, @parent.id].sort)
    end

    it 'returns the downline users' do
      users = @parent.downline_users
      expect(users.map(&:id).sort).to eq(@children.map(&:id).sort)
    end
  end

  describe '#make_customer!' do
    it 'creates a customer record from a user' do
      user = create(:user)
      user.make_customer!

      customer = Customer
                 .where(first_name: user.first_name, last_name: user.last_name).first
      expect(customer).to_not be_nil
    end
  end

  describe '::with_ancestor' do
    it 'finds descendents' do
      root = create(:user)
      parent = create(:user, sponsor: root)
      child = create(:user, sponsor: parent)

      result = User.with_ancestor(root.id)
      expect(result.size).to eq(2)

      result = User.with_ancestor(parent.id).first
      expect(result.id).to eq(child.id)
    end
  end

end
