require 'spec_helper'

describe '/a/notifications' do
  let!(:current_user) { login_user }

  context '#send_out' do
    let(:notification) { create(:notification) }
    let(:delay) { double(:notification_release_delay) }

    before do
      allow(Notification).to receive(:find).with(notification.id)
        .and_return(notification)
    end

    it 'should create a delayed job and save attributes' do
      expect(delay).to receive(:send_out).once
      expect_any_instance_of(NotificationRelease)
        .to receive(:delay).and_return(delay)
      post(
        send_out_admin_notification_path(notification, recipients: 'advocates'),
        format: :json)

      expect_200
      expect(json_body['entities'].length).to eq(1)
      expect(json_body['entities'][0]['properties']['user_full_name'])
        .to eq(current_user.full_name)
      expect(json_body['entities'][0]['properties']['recipient'])
        .to eq('advocates')
      expect(json_body['entities'][0]['properties']['sent_at'])
        .not_to be_nil
      expect(json_body['entities'][0]['properties']['finished_at'])
        .to be_nil
    end

    it 'should require recipients param' do
      expect do
        post(send_out_admin_notification_path(notification), format: :json)
      end.to raise_error(ActionController::ParameterMissing)
    end

    it 'should validate recipient' do
      post(
        send_out_admin_notification_path(notification, recipients: 'wrong'),
        format: :json)

      expect_input_error(:recipient)
    end
  end
end
