require 'spec_helper'

describe '/a/quotes' do

  before do
    login_user(auth: true)
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

    it 'includes the index action' do
      create_list(:quote, 5)
      get admin_quotes_path, format: :json

      expect_actions 'index'
    end

    it 'fuzzy searches by user name and customer name' do
      user = create(:user, last_name: 'Gari')
      customer = create(:customer, last_name: 'Garey')

      create(:quote, user: user)
      create(:quote, customer: customer)

      1.upto(3).each do
        customer = create(:search_miss_customer)
        user = create(:search_miss_user)
        create(:quote, customer: customer, user: user)
      end

      get admin_quotes_path, format: :json, search: 'gary'

      expect_entities_count(2)
    end

    it 'sorts by customer name' do
      quotes = create_list(:quote, 3)
      get admin_quotes_path, format: :json, sort: :customer

      sorted_ids = quotes
                   .sort_by { |q| q.customer.last_name }.map(&:id)
      result = json_body['entities'].map { |e| e['properties']['id'] }

      expect(result).to eq(sorted_ids)
    end
  end

  describe '/:id' do
    it 'includes the related entities' do
      quote = create(:quote)

      get admin_quote_path(quote), format: :json

      %w(product user customer).each do |klass|
        result = json_body['entities'].find { |e| e['class'].include?(klass) }
        expect(result).to be
      end
    end

    it 'includes the create_order action when no order exists' do
      quote = create(:quote)

      get admin_quote_path(quote), format: :json

      action = json_body['actions'].find { |a| a['name'] == 'create_order' }
      expect(action).to_not be_nil
    end

    it 'includes the related order' do
      quote = create(:quote)
      create(:order, quote: quote)

      get admin_quote_path(quote), format: :json

      result = json_body['entities'].find { |e| e['class'].include?('order') }
      expect(result).to_not be_nil
    end
  end

  describe '/:id/subject' do
    before :all do
      ENV['SOLAR_CITY_LEAD_URL'] = 'https://sctyleads-test.cloudhub.io/powur'
    end

    def submit_and_assert_success(cassette)
      quote = create(:complete_quote)

      VCR.use_cassette(cassette) do
        post submit_admin_quote_path(quote), format: :json
      end

      expect_200
      expect(json_body['properties']['provider_uid']).to be
    end

    it 'submits a quote to the solar provider' do
      submit_and_assert_success('quotes/success')
    end

    it 'handles a quote submitted twice but not recorded' do
      submit_and_assert_success('quotes/exists')
    end
  end
end
