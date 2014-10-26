require 'spec_helper'

describe '/u/quotes' do

  before :each do
    login_user

    @quote_field = create(:quote_field, data_type: :lookup)
    create_list(:quote_field_lookup, 4, quote_field: @quote_field)
    @product = @quote_field.product
    SystemSettings.default_product_id = @product.id
  end

  describe '#index' do

    it 'returns the list of quotes for a user' do
      create_list(:quote, 7, user: @user, product: @product)

      get user_quotes_path, format: :json
      expect_classes('list', 'quotes')
      expect_actions('create')

      create_action = json_body['actions'].find { |a| a['name'] == 'create' }
      result = create_action['fields'].any? { |f| f['name'] == @quote_field.name }
      expect(result).to be
    end

  end

  describe '#search' do

    it 'returns a list of quotes for a user matching a search term' do
      create(:quote,
             user:     @user,
             customer: create(:customer, last_name: 'Garey'))
      create(:quote,
             user:     @user,
             customer: create(:customer, last_name: 'Gari'))
      create(:quote,
             user:     @user,
             customer: create(:customer, email: 'gary@example.org'))
      create_list(:quote, 2, user: @user)

      get user_quotes_path, search: 'Gary', format: :json
      expect(json_body['entities'].size).to eq(3)
    end

  end

  describe '#create' do

    let(:input_params) do
      { email:      'newcustomer@example.org',
        first_name: 'Big',
        last_name:  'Money',
        city:       'SunnyVille',
        state:      'FL',
        zip:        '65999',
        utility:    12,
        format:     :json }
    end

    it 'creates a new quote' do
      post user_quotes_path, input_params

      expect_200

      expect_classes 'quote'
    end

    it 'nils out parameters with zero length strings' do
      post user_quotes_path, input_params.merge(city: '', rate_schedule: '')

      expect_200
      expect_classes 'quote'
    end

  end

  describe '#show' do

    it 'returns not found with an invalid user id' do
      get user_quote_path(42), format: :json

      expect_alert_error
    end

    it 'returns a quote detail' do
      quote = create(
        :quote,
        user: @user,
        data: { 'square_feet' => 1200, 'rate_schedule' => 12 })

      get user_quote_path(quote), format: :json

      expect_classes 'quote'
      expect(json_body['properties'].keys)
        .to include('rate_schedule', 'square_feet')
    end

  end

  describe '#update' do

    it 'updates an existing quote' do
      quote = create(:quote, user: @user)

      patch user_quote_path(quote.id, first_name: 'Bob'), format: :json
      quote.reload

      expect_confirm
      expect(json_body['properties']['customer']).to eq(quote.customer.full_name)
    end

  end

  describe '#destroy' do

    it 'deletes a quote' do
      quote = create(:quote, user: @user)

      delete user_quote_path(quote.id), format: :json

      expect_confirm
    end
  end
end
