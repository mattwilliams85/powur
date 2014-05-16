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
end