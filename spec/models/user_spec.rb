require 'spec_helper'

describe User, type: :model do
  describe '@authenticate' do
    let(:password) { 'password123' }

    before do
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

  describe '#mark_notifications_as_read=' do
    let(:user) { create(:user) }

    it 'should write notifications_read_at' do
      expect(user.notifications_read_at).to be_nil
      user.update_attributes(mark_notifications_as_read: 1)
      expect(Time.zone.parse(user.reload.notifications_read_at))
        .to be_within(2.seconds).of(Time.zone.now)
    end
  end

  describe '#latest_unread_notification' do
    let(:user) { create(:user) }
    let!(:notification) { create(:notification) }
    let!(:notification_advocate) { create(:notification) }
    let!(:notification_partner) { create(:notification) }
    before do
      create(:notification_release, notification: notification, recipient: 'advocates')
      create(:notification_release, notification: notification, recipient: 'partners')
      create(:notification_release, notification: notification_advocate, recipient: 'advocates')
      create(:notification_release, notification: notification_partner, recipient: 'partners')
    end

    context 'when have not read them before' do
      it 'returns latest advocate notification' do
        expect(user.latest_unread_notification)
          .to eq(notification_advocate)
      end
    end

    context 'when read something before' do
      before do
        user.update_attribute(:notifications_read_at, Time.zone.now + 1.minute)
      end

      it 'returns latest unread notification' do
        expect(user.latest_unread_notification)
          .to be_nil
      end
    end

    context 'when user is a partner' do
      before do
        allow(user).to receive(:partner?).and_return(true)
      end

      it 'returns partner notification' do
        expect(user.latest_unread_notification)
          .to eq(notification_partner)
      end
    end
  end
end
