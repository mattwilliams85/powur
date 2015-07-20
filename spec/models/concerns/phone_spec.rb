require 'spec_helper'

describe Phone, type: :model do
  describe '#send_sms' do
    let(:user) { create(:user, allow_sms: true) }
    let(:twilio_client) { double('twilio_client') }
    before do
      allow(user).to receive(:twilio_client).and_return(twilio_client)
    end

    context 'when twilio is enabled' do
      before do
        allow(user).to receive(:twilio_enabled?).and_return(true)
      end

      it 'should trigger sms creation' do
        messages = double('messages')
        expect(messages).to receive(:create).with(
          from: ENV['TWILIO_PHONE_NUMBER'],
          to:   '123',
          body: 'text').once
        allow(twilio_client).to receive(:messages).and_return(messages)
        user.send_sms('123', 'text')
      end

      it 'does not send sms if phone number is not provided' do
        expect(twilio_client).not_to receive(:messages)
        user.send_sms(nil, 'content')
      end
    end

    context 'when twilio disabled' do
      before do
        allow(user).to receive(:twilio_enabled?).and_return(false)
      end

      it 'does not send sms' do
        expect(twilio_client).not_to receive(:messages)
        user.send_sms('123', 'content')
      end
    end

    context 'when user disallowed sms' do
      before do
        allow(user).to receive(:allow_sms).and_return('false')
      end

      it 'does not send sms' do
        expect(twilio_client).not_to receive(:messages)
        user.send_sms('123', 'content')
      end
    end
  end
end
