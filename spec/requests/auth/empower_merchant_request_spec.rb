require 'spec_helper'

describe '/u/empower_merchant' do

  before :each do
    login_user
  end

  describe '#sandbox' do
    it "display has the text 'Empower Merchant Sandbox'" do
      get sandbox_empower_merchant_path
      expect_200
      expect(response.body).to match(/Empower Merchant Sandbox/)
    end
  end

  it 'connects to the NMI empower merchant service' do
      req
      post bonus_requirements_path(@bonus), product_id: @product.id,
        source: true, format: :json

      requirements = json_body['entities'].find do |e|
        e['class'].include?('requirements')
      end
      existing = requirements['entities'].find do |e|
        e['properties']['product_id'] == req.product_id
      end
      expect(existing['properties']['source']).to eq(false)
    end
end
