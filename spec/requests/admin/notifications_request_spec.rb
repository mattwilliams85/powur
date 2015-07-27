require 'spec_helper'

describe '/a/notifications' do
  let!(:current_user) { login_user }

  context '#send_out' do
    let(:notification) { create(:notification) }
    let(:delay) { double(:notification_delay) }

    before do
      allow(Notification).to receive(:find).with(notification.id)
        .and_return(notification)
    end

    it 'should create a delayed job and save attributes' do
      expect(delay).to receive(:send_out).once
      expect(notification).to receive(:delay).and_return(delay)
      post(
        send_out_admin_notification_path(notification, recipient: 'advocates'),
        format:    :json)

      expect_200
      expect(notification.sender_id).to eq(current_user.id)
      expect(notification.recipient).to eq('advocates')
      expect(notification.sent_at).to_not eq(nil)
    end

    it 'should require recipient param' do
      expect do
        post(send_out_admin_notification_path(notification), format: :json)
      end.to raise_error(ActionController::ParameterMissing)
    end

    it 'should validate recipient' do
      post(
        send_out_admin_notification_path(notification, recipient: 'wrong'),
        format: :json)

      expect_input_error(:recipient)
    end
  end
end
