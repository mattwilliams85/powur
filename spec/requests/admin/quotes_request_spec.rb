require 'spec_helper'

describe '/a/quotes' do

  before :each do
    login_user
  end

  describe '/' do

    it 'renders a list of quotes' do
      create_list(:quote, 5)
      get admin_quotes_path, format: :json, limit: 3

      expect_classes 'quotes'
      expect_entities_count(3)

      get admin_quotes_path, format: :json, page: 2, limit: 3
      expect_entities_count(2)
    end

    it 'includes the search action' do
      create_list(:quote, 5)
      get admin_quotes_path, format: :json

      expect_actions 'search'
    end

    it 'fuzzy searches by user name and customer name' do
      user = create(:user, last_name: 'Gari')
      customer = create(:customer, last_name: 'Garey')

      create(:quote, user: user)
      create(:quote, customer: customer)
      create_list(:quote, 3)

      get admin_quotes_path, format: :json, search: 'gary'

      expect_entities_count(2)
    end

    it 'sorts by customer name' do
      quotes = create_list(:quote, 3)
      get admin_quotes_path, format: :json, sort: :customer

      sorted_ids = quotes.sort { |a,b| a.customer.last_name <=> b.customer.last_name }.map { |q| q.id }
      result = json_body['entities'].map { |e| e['properties']['id'] }

      expect(result).to eq(sorted_ids)
    end

  end

end
