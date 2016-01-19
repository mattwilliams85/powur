require 'spec_helper'

describe Invite do
  let(:sponsor) { create(:certified_user, available_invites: 4) }
  let(:invite) { create(:invite, sponsor: sponsor) }

  context 'with valid phone number' do
    it 'autogenerates an id' do
      expect(invite.id).to_not be_nil
    end

    it 'autogenerates an expires' do

      expect(invite.expires).to be > (DateTime.current + 23.hours)
    end

    it 'does not allow an empty string on phone' do
      expect { create(:invite, sponsor: sponsor, phone: '') }
        .to raise_error(ActiveRecord::RecordInvalid)
    end

    describe '#accept' do
      let(:user) { invite.accept(params) }
      let(:params) do
        {
          first_name: 'Donald',
          last_name: 'Duck',
          email: 'donald@duck.com',
          password: 'password',
          password_confirmation: 'password'
        }
      end

      before do
        allow(ApplicationAgreement).to receive(:current).and_return(nil)
      end

      it 'should let create a user' do
        expect(user.errors.messages).to be_empty
      end
    end
  end

  context 'invalid phone number' do
    let(:invite) { create(:invite, phone: '1111111111', sponsor: sponsor) }
    before do
      allow_any_instance_of(Invite).to receive(:valid_phone?).and_call_original
    end

    pending 'raises an error' do
      # Phone validation twilio resource is NOT available in test mode,
      # so we just test twilio phone validation integration,
      # the actual error message will be different with production twilio account
      # (https://www.twilio.com/docs/api/rest/test-credentials)
      VCR.use_cassette('twilio_validate_phone_number') do
        expect { invite }.to raise_error(
          Twilio::REST::RequestError,
          'Resource not accessible with Test Account Credentials')
      end
    end
  end
end
