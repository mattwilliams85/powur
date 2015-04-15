require 'spec_helper'

describe '/a/products' do

  before do
    login_user
  end

  describe '#index' do

    it 'returns the list of products' do
      create_list(:product_with_quote_fields, 3)

      get products_path, format: :json

      expect_classes 'products', 'list'
      expect_entities_count(3)
      expect_actions 'create'
    end

  end

  describe '#show' do

    it 'returns the product detail' do
      product = create(:product)

      get product_path(product), format: :json

      expect_classes 'product'
      expect_props id: product.id, name: product.name
    end

  end

  describe '#create' do

    it 'creates a new product' do
      post products_path, name: 'xbox', bonus_volume: 1000, format: :json

      expect_classes 'product'
      expect(json_body['properties']['name']).to eq('xbox')
    end

  end

  describe '#update' do

    it 'updates a product' do
      product = create(:product)

      patch product_path(product),
            bonus_volume: 400,
            format:       :json

      expect(json_body['properties']['bonus_volume']).to eq(400)
    end

  end

  describe '#destroy' do

    it 'deletes a product' do
      product = create(:product)

      delete product_path(product), format: :json

      expect_entities_count(0)
    end

    it 'does not allow a product to be deleted that has existing quotes' do
      product = create(:product)
      create(:quote, product: product)

      delete product_path(product), format: :json

      expect_alert_error
    end

    it 'returns the product sku' do
      product = create(:product)

      get product_path(product), format: :json

      expect_classes 'product'
      expect_props id: product.id, name: product.name
    end
  end
end
