require 'spec_helper'

describe TwilioClient, type: :model do
  let(:client) { TwilioClient.new }

  describe '#purchased_numbers' do
    let(:twilio_numbers_list_response) do
      [
        double(:number1, phone_number: '+123'),
        double(:number1, phone_number: '+456'),
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
    let(:purchased_numbers) { %w(+15005550006 +15005550006) }
    let(:message) { 'Senor Pipito' }

    before do
      allow(client).to receive(:purchased_numbers).and_return(purchased_numbers)
    end

    it 'should send sms using all avaliable purchased phone numbers' do
      expect(client.client.messages).to receive(:create).exactly(3).times.and_call_original

      VCR.use_cassette('twilio_send_group_sms') do
        client.send_sms_in_groups(recipient_numbers, message)
      end
    end
  end
end
