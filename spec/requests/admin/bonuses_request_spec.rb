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

    it 'returns an enroller sales bonus' do
      bonus = create(:enroller_sales_bonus)

      get bonus_path(bonus), format: :json
      expect_classes 'bonus'
    end

    it 'returns an unilevel sales bonus' do
      bonus = create(:unilevel_sales_bonus)

      get bonus_path(bonus), format: :json
      expect_classes 'bonus'
    end

    it 'returns a promote out bonus' do
      bonus = create(:promote_out_bonus)

      get bonus_path(bonus), format: :json
      expect_classes 'bonus'
    end

    it 'returns a differential bonus' do
      bonus = create(:differential_bonus)

      get bonus_path(bonus), format: :json
      expect_classes 'bonus'
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

    it 'updates the bonus name' do
      bonus = create(:direct_sales_bonus)

      patch bonus_path(bonus), name: 'foo', format: :json

      expect(json_body['properties']['name']).to eq('foo')
    end

    it 'updates the max user rank' do
      bonus = create(:enroller_sales_bonus)
      rank = create(:rank)

      patch bonus_path(bonus), max_user_rank_id: rank.id, format: :json

      expect(json_body['properties']['max_user_rank']).to eq(rank.title)
    end

    it 'updates the min upline rank' do
      bonus = create(:differential_bonus)
      rank = create(:rank)

      patch bonus_path(bonus), min_upline_rank_id: rank.id, format: :json

      expect(json_body['properties']['min_upline_rank']).to eq(rank.title)
    end

    it 'updates the flat amount' do
      bonus = create(:promote_out_bonus)

      patch bonus_path(bonus), flat_amount: 42, format: :json

      expect(json_body['properties']['flat_amount']).to eq(42)
    end

    it 'updates the compress flag' do
      bonus = create(:unilevel_sales_bonus)

      compress = bonus.compress
      patch bonus_path(bonus), compress: !compress, format: :json

      expect(json_body['properties']['compress']).to eq(!compress)
    end

  end
end
