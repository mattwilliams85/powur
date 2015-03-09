require 'spec_helper'

describe '/a/bonuses' do

  before do
    login_user
  end

  describe '#index' do

    it 'returns a list of bonuses' do
      bonus = create(:seller_bonus)
      create(:ca_bonus, bonus_plan: bonus.bonus_plan)

      get bonus_plan_bonuses_path(bonus.bonus_plan), format: :json

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
    end

    it 'includes the ca bonus details' do
    end

    it 'includes generational bonus details' do
    end

    it 'includes matching bonus details' do
    end

    describe 'bonus_amounts action' do

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
      end

      it 'always includes the rank_path field' do
        create_list(:rank, 2)
        bonus = create(:bonus_requirement).bonus
        get bonus_path(bonus), format: :json

        expect(rank_path_field).to be
      end

      it 'when null rank_path level defined, no create action' do
        create_list(:rank, 2)
        create_list(:rank_path, 2)
        bonus = create(:bonus_requirement).bonus
        create(:bonus_level, bonus: bonus, rank_path: nil)
        get bonus_path(bonus), format: :json

        expect(create_action).to_not be
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

    it 'creates a seller bonus' do
      bonus_plan = create(:bonus_plan)
      post bonus_plan_bonuses_path(bonus_plan),
           type: 'seller', name: 'foo', format: :json

      expect_classes 'bonus'
    end

    it'creates a ca bonus' do
      bonus_plan = create(:bonus_plan)
      post bonus_plan_bonuses_path(bonus_plan),
           type: 'cab', name: 'foo', format: :json

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
      bonus = create(:seller_bonus)

      patch bonus_path(bonus), name: 'foo', format: :json

      expect(json_body['properties']['name']).to eq('foo')
    end

    it 'updates the compress flag' do
      bonus = create(:generational_bonus)

      compress = bonus.compress
      patch bonus_path(bonus), compress: !compress, format: :json

      expect(json_body['properties']['compress']).to eq(!compress)
    end

  end
end
