require 'spec_helper'

describe '/zip_validator' do
  describe '#create' do
    let(:zip) { '12345' }
    let(:code) { 'qwerty' }
    let!(:customer) { create(:customer, code: code) }

    context 'when valid zip' do
      before do
        allow(Lead).to receive(:valid_zip?).with(zip).and_return(true)
        allow(Lead).to receive(:eligible_zip?).with(zip).and_return(true)
      end

      it 'returns actions data' do
        post zip_validator_path, zip: zip, code: code, format: :json

        expect_200
        expect_props is_valid: true
        expect_actions('solar_invite')
      end
    end

    context 'when invalid zip' do
      before do
        allow(Lead).to receive(:valid_zip?).with(zip).and_return(false)
      end

      it 'returns actions data' do
        post zip_validator_path, zip: zip, code: code

        expect_input_error(:zip)
      end
    end

    context 'when solar api timeout' do
      before do
        allow(RestClient::Request)
          .to receive(:execute).and_raise(RestClient::RequestTimeout)
      end

      it 'defaults to true' do
        post zip_validator_path, zip: zip, code: code, format: :json

        expect_alert_error
      end
    end
  end
end
