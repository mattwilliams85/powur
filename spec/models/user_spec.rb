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

  describe '#remaining_invites' do
    it 'returns the correct number of remaining invites' do
      user = create(:user)
      create_list(:invite, 3, sponsor: user)

      expect(user.remaining_invites).to eq(2)
    end
  end

  describe '#create' do
    let(:user_params) { {} }
    let(:user) { create(:user, user_params) }

    it 'destroys the invite used to create the user' do
      expect(Invite.find_by(email: "#{user.email}")).to be_nil
    end

    describe 'validates latest application and agreement version' do
      subject { user.errors.messages }

      context 'current agreement does not exist' do
        before do
          allow(ApplicationAgreement).to receive(:current).and_return(nil)
        end

        it 'passes validation' do
          expect { user }.not_to raise_error
        end
      end

      context 'current agreement version does not match tos' do
        let(:user_params) { { tos: '1.1' } }

        before do
          allow(ApplicationAgreement).to receive(:current).and_return(double(:agreement, {version: '1.2'}))
        end

        it 'raises error' do
          expect { user }.to raise_error(ActiveRecord::RecordInvalid, 'Outdated terms and conditions')
        end
      end

      context 'agreement version and tos match' do
        let(:user_params) { { tos: '1.2' } }

        before do
          allow(ApplicationAgreement).to receive(:current).and_return(double(:agreement, {version: '1.2'}))
        end

        it 'passes validation' do
          expect { user }.not_to raise_error
        end
      end
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

  describe '#assign_parent' do
    it 'moves a user and their downline in the geneaology' do
      root = create(:user)
      parent1 = create(:user, sponsor: root)
      parent2 = create(:user, sponsor: root)
      child = create(:user, sponsor: parent1)

      parent1.assign_parent(parent2, '')
      expect(parent1.upline).to eq(parent2.upline + [ parent1.id ])
      child.reload
      expect(child.upline).to eq(parent2.upline + [ parent1.id, child.id ])
    end

    it 'does not allow moving a user to a child' do
      root = create(:user)
      parent1 = create(:user, sponsor: root)
      child = create(:user, sponsor: parent1)

      expect { parent1.assign_parent(child) }
        .to raise_error(ArgumentError)
    end
  end

end
