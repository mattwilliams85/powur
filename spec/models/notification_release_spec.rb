require 'spec_helper'

describe NotificationRelease, type: :model do
  context '#send_out' do
    let(:notification) { create(:notification) }
    let(:notification_release) { create(:notification_release) }
    let(:twilio_client) { double(:twilio_client) }
    let(:users) { [double(:user1, phone: '123'), double(:user2, phone: '456')] }

    before do
      expect(TwilioClient).to receive(:new).and_return(twilio_client)
      expect(notification_release).to receive(:fetch_recipients).and_return(users)
    end

    it 'should initiate sending an sms and update finished_at attribute' do
      expect(notification_release.finished_at).to eq(nil)
      expect(twilio_client)
        .to receive(:send_sms_in_groups).with(%w(123 456), notification.content)
      notification_release.send_out
      expect(notification_release.finished_at).not_to eq(nil)
    end
  end

  context '#fetch_recipients' do
    let(:notification) { create(:notification) }
    let(:notification_release) { create(:notification_release) }

    context 'advocates' do
      let(:notification_release) do
        create(:notification_release, recipient: 'advocates')
      end

      it 'should use user advocates scope' do
        expect(User).to receive(:advocates)
          .and_return(double(:advocates, can_sms: [1, 2]))
        expect(notification_release.fetch_recipients).to eq([1, 2])
      end
    end

    context 'partners' do
      let(:notification_release) do
        create(:notification_release, recipient: 'partners')
      end

      it 'should use user partners scope' do
        expect(User).to receive(:partners)
          .and_return(double(:advocates, can_sms: [3, 4]))
        expect(notification_release.fetch_recipients).to eq([3, 4])
      end
    end

    context 'recipient is not set' do
      before do
        notification_release.update_column(:recipient, nil)
      end

      it 'returns empty array' do
        expect(notification_release.fetch_recipients).to eq([])
      end
    end

    context 'invalid recipient' do
      before do
        notification_release.update_column(:recipient, 'cantfind')
      end

      it 'returns empty array' do
        expect(notification_release.fetch_recipients).to eq([])
      end
    end
  end
end
