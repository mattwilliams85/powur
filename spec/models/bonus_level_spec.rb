require 'spec_helper'

describe BonusLevel, type: :model do

  describe '#remaining_percentage' do
    before :each do
      create_list(:rank, 3)
      @product = create(:product, bonus_volume: 500)
    end

    describe 'with multiple bonus levels' do
      it 'returns the correct value' do
        bonus = create(:bonus_requirement, product: @product).bonus
        create(:bonus_level, bonus: bonus, amounts: [ 0.1, 0.2, 0.4 ])

        unilevel = create(:unilevel_sales_bonus)
        create(:bonus_requirement, bonus: unilevel, product: @product)
        create(:bonus_level, bonus: unilevel, level: 1, amounts: [ 0.05, 0.1, 0.15 ])

        bonus_level = create(:bonus_level, bonus: unilevel, level: 2)

        expect(bonus_level.remaining_percentage).to eq(0.45)
        remaining_amount = bonus_level.remaining_percentage * bonus_level.available_amount
        expect(bonus_level.remaining_amount).to eq(remaining_amount)
      end
    end
  end
end
