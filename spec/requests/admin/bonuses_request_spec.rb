require 'spec_helper'

describe '/a/bonuses' do

  before do
    login_user
  end

  let(:bonus_plan) { create(:bonus_plan) }

  describe '#index' do

    it 'returns a list of bonuses' do
      create(:seller_bonus, bonus_plan: bonus_plan)
      create(:ca_bonus, bonus_plan: bonus_plan)

      get bonus_plan_bonuses_path(bonus_plan), format: :json

      expect_classes 'bonuses', 'list'
      expect_entities_count(2)
    end

  end

  describe '#show' do

    it 'returns the bonus detail' do
      bonus = create(:seller_bonus)
      create_list(:rank, 3)
      get bonus_path(bonus), format: :json

      expect_classes 'bonus'
      expect_entities_count(1)

      update = json_body['actions'].find { |a| a['name'] == 'update' }
      bonus.class.meta_data_fields.each do |key, type|
        result = update['fields'].any? { |f| f['name'] == key.to_s }
        expect(result).to be
      end
    end

    it 'includes the ca bonus details' do
    end

    it 'includes generational bonus details' do
    end

    it 'includes matching bonus details' do
    end
  end

  describe '#create' do

    it 'creates a seller bonus' do
      post bonus_plan_bonuses_path(bonus_plan, format: :json),
           type: 'SellerBonus', name: 'foo'

      expect_classes 'bonus'
    end

    it'creates a ca bonus' do
      post bonus_plan_bonuses_path(bonus_plan),
           type: 'CABonus', name: 'foo', format: :json

      expect_classes 'bonus'
    end

  end

  describe '#destroy' do

    it 'destroys a bonus' do
      bonus_plan = create(:bonus_plan)
      bonus = create(:seller_bonus, bonus_plan: bonus_plan)

      create_list(:seller_bonus, 2, bonus_plan: bonus_plan)
      delete bonus_path(bonus), format: :json

      expect_classes 'bonuses', 'list'
      expect_entities_count(2)
    end

  end

  describe '#update' do

    it 'updates the bonus name' do
      bonus = create(:seller_bonus)

      patch bonus_path(bonus), name: 'foo', format: :json

      expect(json_body['properties']['name']).to eq('foo')
    end

  end
end
