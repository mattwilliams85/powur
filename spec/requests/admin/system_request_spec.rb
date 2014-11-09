require 'spec_helper'

describe '/a/system' do

  before :each do
    login_user
  end

  describe 'GET /' do
    it 'includes the actions' do
      get system_path, format: :json

      expect_classes 'data'
      expect_actions 'quotes'
    end
  end

  describe 'GET /quotes' do
    it 'returns a csv file' do
      product = create(:sunrun_product)
      create_list(:complete_quote, 4, product: product)
      create(:quote, product: product)
      get quotes_system_path, format: :json

      expect(response.headers['Content-Type']).to eq('text/csv')

      csv = CSV.parse(response.body)
      expect(csv.length).to eq(5)
    end
  end
end
