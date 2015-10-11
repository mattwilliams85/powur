require 'spec_helper'

describe '/zip_validator' do
  describe '#create' do
    context 'when valid zip' do
      before do
        allow(Net::HTTP)
          .to receive(:get)
          .with('api.solarcity.com', '/solarbid/api/warehouses/zip/' + zip)
          .and_return('{"IsInTerritory": true}')
      end

      let(:zip) { '12345' }
      let(:code) { 'qwerty' }
      let!(:customer) { create(:customer, code: code) }

      it 'returns actions data' do
        post zip_validator_path, zip: zip, code: code

        expect_200
        expect_props is_valid: true
        expect_actions('solar_invite')
      end
    end

    context 'when invalid zip' do
      before do
        allow(Net::HTTP)
          .to receive(:get)
          .and_return('{"IsInTerritory": false}')
      end

      let(:zip) { '11111' }

      it 'returns actions data' do
        post zip_validator_path, zip: zip

        expect_200
        expect_props is_valid: false
      end
    end
  end
end
