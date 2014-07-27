require 'spec_helper'

describe '/a/bonuses/:id/bonus_levels' do

  before :each do
    login_user
    create_list(:rank, 3)
    @bonus = create(:unilevel_sales_bonus)
    create(:bonus_requirement, bonus: @bonus)
  end

  describe '#create' do

    it 'adds a bonus level to to a bonus' do
      post bonus_levels_path(@bonus), amounts: [ 0.1, 0.4, 0.125 ], format: :json

      expect_classes 'bonus'
      bonus_levels = json_body['entities'].find { |e| e['class'].include?('bonus_levels') }
      expect(bonus_levels['entities'].size).to eq(1)
    end
  end

  describe '#update' do

  end

  describe '#destroy' do

  end

end
