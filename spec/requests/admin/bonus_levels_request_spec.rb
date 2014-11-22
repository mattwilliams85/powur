require 'spec_helper'

describe '/a/bonuses/:id/bonus_levels' do

  before :each do
    login_user
    create_list(:rank, 4)
    @bonus = create(:unilevel_sales_bonus)
    create(:bonus_requirement, bonus: @bonus)
  end

  describe '#create' do

    it 'adds a bonus level to to a bonus' do
      post bonus_levels_path(@bonus),
           amounts: [ 0.1, 0.4, 0.125 ], format: :json

      expect_classes 'bonus'
      bonus_levels = json_body['entities']
        .find { |e| e['class'].include?('bonus_levels') }
      expect(bonus_levels['entities'].size).to eq(1)
      padded_value = bonus_levels['entities']
        .first['properties']['amounts'].last
      expect(padded_value).to eq(0.0)
    end

  end

  describe '#update' do

    it 'updates a bonus level' do
    end

  end

  describe '#destroy' do

    before :each do
      @levels = 1.upto(3).map do |i|
        create(:bonus_level, level: i, bonus: @bonus)
      end
    end

    it 'removes the last bonus_level' do
      delete bonus_level_path(@levels.last), format: :json

      bonus_levels = json_body['entities']
        .find { |e| e['class'].include?('bonus_levels') }
      expect(bonus_levels['entities'].size).to eq(2)
    end

  end

end
