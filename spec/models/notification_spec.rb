require 'spec_helper'

describe Notification, type: :model do

  context '#send_out' do
    let(:notification) { create(:notification) }
    let(:users) { [double(:user1, phone: '123'), double(:user2, phone: '456')] }

    before do
      expect(notification).to receive(:fetch_recipients).and_return(users)
    end

    it 'should initiate sending an sms and update finished_at attribute' do
      users.each do |user|
        expect(user).to receive(:send_sms).with(user.phone, notification.content).once
      end
      expect(notification.finished_at).to eq(nil)
      notification.send_out
      expect(notification.finished_at).not_to eq(nil)
    end
  end

  context '#fetch_recipients' do
    let(:notification) { create(:notification) }

    context 'advocates' do
      let(:notification) { create(:notification, recipient: 'advocates') }

      it 'should use user advocates scope' do
        expect(User).to receive(:advocates).and_return([1, 2])
        expect(notification.fetch_recipients).to eq([1, 2])
      end
    end

    context 'partners' do
      let(:notification) { create(:notification, recipient: 'partners') }

      it 'should use user partners scope' do
        expect(User).to receive(:partners).and_return([3, 4])
        expect(notification.fetch_recipients).to eq([3, 4])
      end
    end

    context 'recipient is not set' do
      before do
        notification.update_column(:recipient, nil)
      end

      it 'returns empty array' do
        expect(notification.fetch_recipients).to eq([])
      end
    end

    context 'invalid recipient' do
      before do
        notification.update_column(:recipient, 'cantfind')
      end

      it 'returns empty array' do
        expect(notification.fetch_recipients).to eq([])
      end
    end
  end
end
