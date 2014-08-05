require 'spec_helper'

describe '/a/quotes' do

  before :each do
    login_user
  end

  describe '/' do

    before :each do
      @quotes = create_list(:quote, 5)
    end

    it 'renders a list of quotes' do
      get admin_quotes_path, format: :json, limit: 3

      expect_classes 'quotes'
      expect_entities_count(3)

      get admin_quotes_path, format: :json, p: 2, limit: 3
      expect_entities_count(2)
    end

    it 'sorts by customer name' do
      get admin_quotes_path, format: :json, sort: :customer

      sorted_ids = @quotes.sort { |a,b| a.customer.last_name <=> b.customer.last_name }.map { |q| q.id }
      result = json_body['entities'].map { |e| e['properties']['id'] }

      expect(result).to eq(sorted_ids)
    end

  end

end
