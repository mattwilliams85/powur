require 'spec_helper'

describe '/a/orders' do

  before :each do
    login_user
  end

  describe 'GET /' do

    it 'pages orders' do
      create_list(:order, 5)
      get orders_path, format: :json, limit: 3

      expect_entities_count(3)

      get orders_path, format: :json, limit: 3, page: 2

      expect_entities_count(2)
    end

    it 'fuzzy searches by user name and customer name' do
      user = create(:user, last_name: 'Gari')
      customer = create(:customer, last_name: 'Garey')

      create(:order, user: user)
      create(:order, customer: customer)
      create_list(:order, 3)

      get orders_path, format: :json, search: 'gary'

      expect_entities_count(2)
    end

  end

  describe 'POST /' do

    it 'creates an order from a quote' do
      quote = create(:quote)

      post orders_path, quote_id: quote.id, format: :json

      expect_classes 'order'
    end

    it 'does not allow an order to be created when one already exists for a quote' do
      order = create(:order)

      post orders_path, quote_id: order.quote_id, format: :json

      expect_alert_error
    end
  end
end