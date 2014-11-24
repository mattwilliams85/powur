require 'spec_helper'

describe '/a/bonuses' do

  before :each do
    login_user
  end

  describe '#index' do

    it 'returns a list of bonuses' do
      bonus_plan = create(:bonus_plan)
      create_list(:direct_sales_bonus, 3, bonus_plan: bonus_plan)

      get bonus_plan_bonuses_path(bonus_plan), format: :json

      expect_classes 'bonuses', 'list'
      expect_entities_count(3)
    end

  end

  describe '#show' do

    it 'returns the bonus detail including requirements' do
      bonus = create(:bonus_requirement).bonus
      create_list(:rank, 3)
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
      create_list(:rank, 3)
      bonus = create(:unilevel_sales_bonus)
      create(:bonus_requirement, bonus: bonus)
      create(:bonus_level, bonus: bonus,
             level: 1, amounts: [ 0.125, 0.125, 0.125, 0.125 ])

      get bonus_path(bonus), format: :json

      expect_classes 'bonus'
      bonus_levels = json_body['entities'].find do |e|
        e['class'].include?('bonus_levels')
      end
      expect(bonus_levels).to be
      create = bonus_levels['actions'].find { |a| a['name'] == 'create' }
      expect(create).to be
    end

    it 'returns a promote-out bonus' do
      bonus = create(:promote_out_bonus)
      create(:bonus_requirement, bonus: bonus)
      create(:bonus_requirement, bonus: bonus, source: false)

      get bonus_path(bonus), format: :json

      expect_classes 'bonus'
    end

    it 'returns a differential bonus' do
      bonus = create(:differential_bonus)
      get bonus_path(bonus), format: :json

      expect_classes 'bonus'
    end

    describe 'bonus_level action' do

      def create_action
        levels = json_body['entities'].find do |e|
          e['class'].include?('bonus_levels')
        end
        levels['actions'] &&
          levels['actions'].find { |a| a['name'] == 'create' }
      end

      def rank_path_field
        action = create_action
        action['fields'].find { |f| f['name'] == 'rank_path_id' }
      end

      def expect_rank_path_field(options_count, required)
        field = rank_path_field

        expect(field).to be
        expect(field['options'].size).to eq(options_count)
        expect(field['required']).to eq(required)
      end

      it 'does not include the rank_path field with no paths' do
        create_list(:rank, 2)
        bonus = create(:bonus_requirement).bonus
        get bonus_path(bonus), format: :json

        expect(rank_path_field).to_not be
      end

      it 'when null rank_path level defined, no create action' do
        create_list(:rank, 2)
        create_list(:rank_path, 2)
        bonus = create(:bonus_requirement).bonus
        create(:bonus_level, bonus: bonus, rank_path: nil)
        get bonus_path(bonus), format: :json

        expect(create_action).to_not be
      end

      it 'when only one path choice left, rank_path field has 1 option' do
        create_list(:rank, 2)
        rank_paths = create_list(:rank_path, 2)
        bonus = create(:bonus_requirement).bonus
        create(:bonus_level, bonus: bonus, rank_path: rank_paths.first)
        get bonus_path(bonus), format: :json

        expect_rank_path_field(1, true)
      end

      it 'includes the rank_path field with 2 paths' do
        create_list(:rank, 2)
        create_list(:rank_path, 2)
        bonus = create(:bonus_requirement).bonus
        get bonus_path(bonus), format: :json

        expect_rank_path_field(2, false)
      end
    end
  end

  describe '#create' do

    it 'creates a direct sales bonus' do
      bonus_plan = create(:bonus_plan)
      post bonus_plan_bonuses_path(bonus_plan),
           type: 'direct_sales', name: 'foo', format: :json

      expect_classes 'bonus'
    end

  end

  describe '#destroy' do

    it 'destroys a bonus' do
      bonus_plan = create(:bonus_plan)
      bonus = create(:direct_sales_bonus, bonus_plan: bonus_plan)
      create(:bonus_requirement, bonus: bonus)

      create_list(:direct_sales_bonus, 2, bonus_plan: bonus_plan)
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

      patch bonus_path(bonus), flat_amount: 42.0, format: :json

      expect(json_body['properties']['flat_amount']).to eq('42.0')
    end

    it 'updates the compress flag' do
      bonus = create(:unilevel_sales_bonus)

      compress = bonus.compress
      patch bonus_path(bonus), compress: !compress, format: :json

      expect(json_body['properties']['compress']).to eq(!compress)
    end

  end
end
