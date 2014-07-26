require 'spec_helper'

describe Bonus, type: :model do

  it 'returns the source bonus volume' do
    product = create(:product)

    bonus = create(:bonus_requirement, product: product).bonus

    expect(bonus.available_bonus_amount).to eq(product.bonus_volume)
  end

  describe '#available_bonus_amount' do
    it 'returns 100% when 0 other defined bonuses' do
      product = create(:product)

      bonus = create(:bonus_requirement, product: product).bonus

      expect(bonus.available_bonus_percentage).to eq(1.0)
    end

    it 'returns the right percentage with 1 other bonus' do
      create_list(:rank, 5)
      product = create(:product)

      bonus1 = create(:bonus_requirement, product: product).bonus

      bonus_level = create(:bonus_level, bonus: bonus1)

      bonus2 = create(:bonus_requirement, product: product).bonus

      expect(1.0 - bonus1.max_bonus_amount).
        to eq(bonus2.available_bonus_percentage)
    end
  end
  

end