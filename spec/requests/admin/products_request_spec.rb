require 'spec_helper'

describe '/a/products' do

  before :each do
    login_user
  end

  describe '#index' do

    it 'returns the list of products' do
      create_list(:product, 3)

      get products_path

      expect_classes 'products', 'list'
      expect_entities_count(4)
      expect_actions 'create'
    end

  end

  describe '#show' do

    it 'returns the product detail' do
      product = create(:product)

      get product_path(product)

      expect_classes 'product'
      expect(json_body['properties'].keys).to include('quote_data')
    end

  end

  describe '#create' do

    it 'creates a new product' do
      post products_path, name: 'xbox', commissionable_volume: 1000

      expect_classes 'product'
      expect(json_body['properties']['name']).to eq('xbox')
    end

  end

  describe '#update' do

    it 'updates a product' do
      product = create(:product)

      patch product_path(product), commissionable_volume: 400, quote_data: %w(foo bar)

      expect(json_body['properties']['commissionable_volume']).to eq(400)
      expect(json_body['properties']['quote_data']).to eq(%w(foo bar))
    end

  end

  describe '#destroy' do

    it 'deletes a product' do
      product = create(:product)

      delete product_path(product)

      expect_entities_count(1)
    end

    it 'does not allow a product to be deleted that has existing quotes' do
      product = create(:product)
      create(:quote, product: product)

      delete product_path(product)

      expect_alert_error
    end

  end

end