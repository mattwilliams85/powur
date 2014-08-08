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

    it 'includes the create_order action when no order exists' do
      quote = create(:quote)

      get admin_quotes_path, format: :json

      quote = json_body['entities'].first
      action = quote['actions'].find { |a| a['name'] == 'create_order'}
      expect(action).to_not be_nil
    end

    it 'includes the related order when an order exists' do
      quote = create(:quote)
      order = create(:order, quote: quote)

      get admin_quotes_path, format: :json

      quote = json_body['entities'].first
      expect(quote['actions']).to be_nil
      order = quote['entities'].first
      expect(order['class']).to include('order')
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
