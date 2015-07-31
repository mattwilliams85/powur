require 'spec_helper'

describe TwilioClient, type: :model do
  let(:client) { TwilioClient.new }
  let!(:twilio_account_sid) do
    create(:system_setting,
           var:   'twilio_account_sid',
           value: ENV['TWILIO_ACCOUNT_SID'])
  end
  let!(:twilio_auth_token) do
    create(:system_setting,
           var:   'twilio_auth_token',
           value: ENV['TWILIO_AUTH_TOKEN'])
  end

  describe '#purchased_numbers' do
    let(:twilio_numbers_list_response) do
      [
        double(:number1, phone_number: '+123'),
        double(:number2, phone_number: '+456')
      ]
    end

    it 'should get a list of phone numbers' do
      expect(client.account.incoming_phone_numbers)
        .to receive(:list).with({}).and_return(twilio_numbers_list_response)
      expect(client.purchased_numbers).to eq(%w(+123 +456))
    end
  end

  describe '#send_sms_in_groups' do
    let(:recipient_numbers) { %w(+15005550007 +15005550005 +15005550007) }
    let(:purchased_numbers) { %w(+15005550006 15005550006) }
    let(:message) { 'Senor Pipito' }

    before do
      allow(client).to receive(:purchased_numbers).and_return(purchased_numbers)
    end

    it 'should send sms using all avaliable purchased phone numbers' do
      sent_messages = []
      VCR.use_cassette(
        'twilio_send_group_sms',
        match_requests_on: [ :host, :method ]) do
        sent_messages = client.send_sms_in_groups(recipient_numbers, message)
      end
      expect(sent_messages.length).to eq(3)
      3.times do |i|
        expect(purchased_numbers).to include(sent_messages[i].from)
        expect(sent_messages[i].to).to eq(recipient_numbers[i])
        expect(sent_messages[i].body).to eq(message)
      end
    end
  end
end
