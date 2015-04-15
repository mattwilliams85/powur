require 'spec_helper'

describe 'order endpoints' do

  before do
    DatabaseCleaner.clean
    login_user
  end

  describe 'GET /a/orders' do

    it 'pages orders' do
      create_list(:order, 5)
      get admin_orders_path, format: :json, limit: 3

      expect_entities_count(3)

      get admin_orders_path, format: :json, limit: 3, page: 2

      expect_entities_count(2)
    end

    it 'fuzzy searches by user name and customer name' do
      user = create(:user, last_name: 'Gari')
      customer = create(:customer, last_name: 'Garey')

      create(:order, user: user)
      create(:order, customer: customer)

      3.times.each do
        user = create(:search_miss_user)
        customer = create(:search_miss_customer)
        create(:order, user: user, customer: customer)
      end

      get admin_orders_path, format: :json, search: 'gary'

      expect_entities_count(2)
    end

    it 'sorts and pages orders' do
      users = %w(aaa ddd bbb ggg ccc).map do |last_name|
        user = create(:user, last_name: last_name)
        create(:order, user: user)
        user
      end

      get admin_orders_path, format: :json, sort: 'user', limit: 3, page: 2

      result = json_body['entities'].map { |e| e['properties']['distributor'] }
      expected = %w(ddd ggg).map do |name|
        users.find { |u| u.last_name == name }.full_name
      end

      expect(result).to eq(expected)
    end

  end

  describe 'POST /a/orders' do
    it 'creates an order from a quote' do
      quote = create(:quote)

      post admin_orders_path,
           quote_id:   quote.id,
           order_date: '2014-07-27T22:11:14.599Z',
           format:     :json

      expect_classes 'order'
    end

    it 'does not allow an order to be if when one already exists for a quote' do
      order = create(:order)

      post admin_orders_path, quote_id: order.quote_id, format: :json

      expect_alert_error
    end
  end

  describe 'GET /a/orders/:id' do
    it 'includes the related entities' do
      create(:rank)
      order = create(:order)
      create(:bonus_payment_order, order: order)

      get admin_order_path(order), format: :json
      %w(product user customer bonus_payments).each do |klass|
        result = json_body['entities'].find { |e| e['class'].include?(klass) }
        expect(result).to be
      end
    end
  end

  describe 'GET /users/:id/orders' do
    it 'renders orders for a user' do
      create(:order)
      user = create(:user)
      create_list(:order, 3, user: user)

      get admin_user_orders_path(user), format: :json

      expect_entities_count(3)
    end
  end

  describe 'GET /a/pay_periods/:id/orders' do
    it 'renders orders for a pay_period' do
      pay_period = create(:monthly_pay_period)
      create_list(:order, 3, order_date: pay_period.start_date + 1.day)

      get pay_period_orders_path(pay_period), format: :json

      expect_entities_count(3)
    end

  end

end
