require 'spec_helper'

describe '/a/bonuses/:admin_bonus_id/bonus_levels' do

  before :each do
    login_user
    create_list(:rank, 4)
    @bonus = create(:unilevel_sales_bonus)
    create(:bonus_requirement, bonus: @bonus)
    @path = create(:rank_path)
  end

  describe 'POST /' do

    it 'adds a bonus level to to a bonus' do
      post bonus_levels_path(@bonus),
           rank_path_id: @path.id,
           amounts:      [ 0.1, 0.4, 0.125 ],
           format:       :json

      expect_classes 'bonus'

      bonus_levels = json_body['entities'].find do |e|
        e['class'].include?('bonus_levels')
      end
      expect(bonus_levels['entities'].size).to eq(1)

      level = bonus_levels['entities'].first
      expect(level['properties']['rank_path']).to eq(@path.name)

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

  end

  describe 'PATCH /:id' do

    it 'updates a bonus level' do
    end

  end

  describe 'DELETE /:id' do

    before :each do
      @levels = 1.upto(3).map do |i|
        create(:bonus_level, level: i, bonus: @bonus)
      end
    end

    it 'removes the last bonus_level' do
      delete bonus_level_path(@levels.last), format: :json

      bonus_levels = json_body['entities'].find do |e|
        e['class'].include?('bonus_levels')
      end
      expect(bonus_levels['entities'].size).to eq(2)
    end

  end

end
