require 'spec_helper'

describe '/a/data' do

  before :each do
    login_user
  end

  describe 'GET /' do
    it 'includes the actions' do
      get data_path, format: :json

      expect_classes 'data'
      expect_actions 'quotes'
    end
  end

  describe 'GET /quotes' do
    it 'returns a csv file' do
      data = { 'utility'       => 1,
               'average_bill'  => 230,
               'rate_schedule' => 2,
               'square_feet'   => 2000 }
      create_list(:quote, 4, data: data)
      get quotes_data_path, format: :json

      expect(response.headers['Content-Type']).to eq('text/csv')

      csv = CSV.parse(response.body)
      expect(csv.length).to eq(5)
    end
  end
end
