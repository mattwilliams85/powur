require 'spec_helper'

describe Bonus, type: :model do

  it 'returns the source bonus volume' do
    product = create(:product)

    bonus = create(:bonus_requirement, product: product).bonus

    expect(bonus.available_amount).to eq(product.bonus_volume)
  end

  describe '#available_amount' do
    it 'returns 100% when 0 other defined bonuses' do
      product = create(:product)

      bonus = create(:bonus_requirement, product: product).bonus

      expect(bonus.remaining_percentage).to eq(1.0)
    end

    it 'returns the right percentage with other bonuses' do
      create_list(:rank, 3)
      product = create(:product)

      bonus1 = create(:bonus_requirement, product: product).bonus
      bonus2 = create(:bonus_requirement, product: product).bonus
      bonus3 = create(:bonus_requirement, product: product).bonus

      amounts1 = [ 0.1, 0.3, 0.2 ]
      amounts2 = [ 0.45, 0.3, 0.2 ]
      create(:bonus_level, bonus: bonus1, level: 0, amounts: amounts1)
      create(:bonus_level, bonus: bonus2, level: 0, amounts: amounts2)

      expect(bonus3.remaining_percentage).to eq(1.0 - (amounts1.max + amounts2.max))
      expect(bonus3.remaining_percentage * bonus3.available_amount).to eq(bonus3.remaining_amount)

      result = bonus1.percentage_used + bonus2.percentage_used + bonus3.remaining_percentage
      expect(result).to eq(1.0)
    end
  end
  

end