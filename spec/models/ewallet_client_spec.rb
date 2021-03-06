require 'spec_helper'

describe EwalletClient, type: :model do
  let(:client) { described_class.new }
  let(:user) { create(:user, user_params) }
  let(:email) { 'ewallet_create_test@example.com' }
  let(:user_params) { { email: email, ewallet_username: email } }

  context 'when making ewallet load request' do
    let(:batch_id) { 'Test bonus payment on 8/11/2015' }
    let(:payment) do
      { ref_id:   12,
        username: email,
        amount:   34
      }
    end

    let(:expected_ewallet_load_response) do
      { 'ACHTransactionID'              => 0,
        'CurrencyCode'                  => nil,
        'CustomerFeeAmount'             => 0.0,
        'LogTransactionID'              => 0,
        'ProcessorTransactionRefNumber' => '',
        'TransactionRefID'              => 35_371,
        'm_Code'                        => 0,
        'm_Text'                        => 'OK' }
    end

    before do
      VCR.use_cassette('ewallet_create') do
        client.create(user)
      end
    end

    describe '#ewallet_load' do
      it 'should return successful response' do
        VCR.use_cassette('ewallet_load') do
          expect(client.ewallet_load(batch_id: batch_id, payments: [payment]))
            .to eq(expected_ewallet_load_response)
        end
      end
    end

    describe '#ewallet_individual_load' do
      it 'should return successful response' do
        VCR.use_cassette('ewallet_load') do
          expect(
            client.ewallet_individual_load(
              batch_id: batch_id,
              payment:  payment))
            .to eq(expected_ewallet_load_response)
        end
      end

      context 'ewallet does not exist' do
        let(:payment) do
          { ref_id:   1,
            username: 'doesnotexist@example.com',
            amount:   111
          }
        end

        it 'should unset ewallet_username' do
          VCR.use_cassette('ewallet_load_not_found') do
            expect do
              client.ewallet_individual_load(
                batch_id: batch_id,
                payment:  payment)
            end.to raise_error(
              Ipayout::Error::EwalletNotFound,
              'Customer with user name doesnotexist@example.com is not found')
          end
        end
      end
    end
  end
end
