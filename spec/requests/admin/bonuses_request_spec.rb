require 'spec_helper'

describe '/a/bonuses' do

  before :each do
    login_user
  end

  describe '#index' do

    it 'returns a list of bonuses' do
      create_list(:direct_sales_bonus, 3)

      get bonuses_path, format: :json

      expect_classes 'bonuses', 'list'
      expect_entities_count(3)
    end

  end

  describe '#show' do

    it 'returns the bonus detail including requirements' do
      bonus = create(:bonus_requirement).bonus

      get bonus_path(bonus), format: :json

      expect_classes 'bonus'
      expect_entities_count(2)
      expect(json_body['entities'].first['entities'].size).to eq(1)
    end

  end

  describe '#create' do

    it 'creates a direct sales bonus' do
      post bonuses_path, type: 'direct_sales', name: 'foo', format: :json

      expect_classes 'bonus'
    end

  end

  describe '#destroy' do

    it 'destroys a bonus' do
      bonus = create(:bonus_requirement).bonus

      create_list(:direct_sales_bonus, 2)
      delete bonus_path(bonus), format: :json

      expect_classes 'bonuses', 'list'
      expect_entities_count(2)
    end

  end

  describe '#update' do

    it 'updates bonus details' do
      # bonus = create(:bonus)
            #   type:       :direct_sales, 
      #   amounts:    [150, 200, 200],
      #   product_id: @product.id,
      #   period:     :weekly,
      #   format:     :json

    end
  end
end