require 'spec_helper'

describe User, type: :model do
  let(:user) { create(:user, user_params) }
  let(:email) { 'ewallet_create_test@example.com' }
  let(:user_params) { { email: email, ewallet_username: email } }

  describe '#ewallet?' do
    it 'should return true when ewallet_username is set' do
      expect(user.ewallet?).to eq(true)
    end

    it 'should return false when NO ewallet_username set' do
      user.update_attributes!(ewallet_username: nil)
      expect(user.ewallet?).to eq(false)
    end
  end

  describe '#ewallet' do
    context 'when ewallet exists' do
      let(:ewallet_client) { EwalletClient.new }
      before do
        VCR.use_cassette('ewallet_create') do
          ewallet_client.create(user)
        end
      end

      it 'should return success response' do
        VCR.use_cassette('ewallet_fetch') do
          expect(user.ewallet).not_to be_nil
          expect(user.ewallet[:m_Text]).to eq('OK')
          expect(user.ewallet[:Email]).to eq(email)
        end
      end
    end

    context 'when ewallet does not exist' do
      let(:user_params) { { ewallet_username: 'nope@example.com' } }

      it 'should return nil' do
        VCR.use_cassette('ewallet_fetch_not_found') do
          expect(user.ewallet).to be_nil
        end
      end
    end
  end

  describe '#ewallet!' do
    context 'when all data is valid' do
      it 'should return true and update user record with ewallet_username' do
        VCR.use_cassette('ewallet_create') do
          expect(user.ewallet!).to eq(true)
          expect(user.reload.ewallet_username).to eq(user.email)
        end
      end
    end

    context 'when user has no email' do
      before do
        user.email = nil
      end

      it 'should raise an error' do
        VCR.use_cassette('ewallet_create_error') do
          expect { user.ewallet! }
            .to raise_error(RuntimeError, 'User Name is Required')
        end
      end
    end

    context 'when ewallet already exists' do
      it 'should return true and update user record with ewallet_username' do
        VCR.use_cassette('ewallet_create_already_exists') do
          expect(user.ewallet!).to eq(true)
          expect(user.reload.ewallet_username).to eq(user.email)
        end
      end
    end
  end
end
