require 'spec_helper'

describe '/a/bonuses/:admin_bonus_id/bonus_levels' do

  before :each do
    login_user
    create_list(:rank, 4)
    @path = create(:rank_path)
  end
  
  def amounts
    json_body['entities'].find { |e| e['class'].include?('bonus_levels') }
  end

  def create_action
    amounts['actions'].find { |a| a['name'] == 'create' }
  end

  describe 'POST /' do

    it 'adds a bonus level to to a bonus' do
      bonus = create(:unilevel_bonus)
      create(:bonus_requirement, bonus: bonus)
      post bonus_levels_path(bonus),
           rank_path_id: @path.id,
           amounts:      [ 0.1, 0.4, 0.125 ],
           format:       :json

      expect_classes 'bonus'

      bonus_levels = json_body['entities'].find do |e|
        e['class'].include?('bonus_levels')
      end
      expect(bonus_levels['entities'].size).to eq(1)

      level = bonus_levels['entities'].first
      expect(level['properties']['rank_path']['name']).to eq(@path.name)

      padded_value = level['properties']['amounts'].last
      expect(padded_value).to eq('0.0')
    end

    it 'does not allow bonus amounts when the bonus has no source' do
      bonus = create(:direct_sales_bonus)
      post bonus_levels_path(bonus),
           rank_path_id: @path.id,
           amounts:      [ 0.1, 0.4, 0.125 ],
           format:       :json

      expect_alert_error
    end

    it 'adds a bonus level to a standard bonus' do
      bonus = create(:direct_sales_bonus)
      create(:bonus_requirement, bonus: bonus)
      post bonus_levels_path(bonus),
           rank_path_id: @path.id,
           amounts:      [ 0.1, 0.4, 0.125 ],
           format:       :json

      expect_classes 'bonus'
    end

    it 'fills the bonus level with other paths' do
      path2 = create(:rank_path)
      bonus = create(:bonus_requirement).bonus
      post bonus_levels_path(bonus),
           rank_path_id: @path.id,
           amounts:      [ 0.1, 0.4, 0.125 ],
           format:       :json

      expect(amounts.size).to eq(2)
    end

    it 'allows a bonus level without a rank path' do
      bonus = create(:bonus_requirement).bonus
      post bonus_levels_path(bonus),
           rank_path_id: nil,
           amounts:      [ 0.1, 0.4, 0.125 ],
           format:       :json

      expect(amounts['entities'].size).to eq(1)
      bonus_level = amounts['entities'].first
      expect(bonus_level['properties']['rank_path']['name']).to_not be
    end

    it 'allows multiple levels for a unilevel bonus' do
      path2 = create(:rank_path)
      bonus = create(:unilevel_bonus)
      create(:bonus_requirement, bonus: bonus)
      post bonus_levels_path(bonus),
           rank_path_id: @path.id,
           amounts:      [ 0.1, 0.4, 0.125 ],
           format:       :json

      expect(amounts['entities'].size).to eq(2)

      post bonus_levels_path(bonus),
           rank_path_id: nil,
           amounts:      [ 0.1, 0.4, 0.125 ],
           format:       :json
      expect(amounts['entities'].size).to eq(3)
    end
  end

  describe 'PATCH /:id' do

    it 'updates a bonus level' do
    end

  end

  describe 'DELETE /:id' do

    it 'removes the last bonus_level' do
      bonus = create(:unilevel_bonus)
      create(:bonus_requirement, bonus: bonus)
      levels = 1.upto(3).map do |i|
        create(:bonus_level, level: i, bonus: bonus)
      end
      delete bonus_level_path(levels.last), format: :json

      bonus_levels = json_body['entities'].find do |e|
        e['class'].include?('bonus_levels')
      end
      expect(bonus_levels['entities'].size).to eq(2)
    end

  end

end
