require 'spec_helper'

describe Bonus, type: :model do
  
  describe '#amount_used' do
    it 'returns zero when no amounts defined' do
      bonus = create(:bonus)

      expect(bonus.amount_used).to eq(0.0)
    end

    it 'returns the max amount used' do
      amount = create(:bonus_amount, amounts: [ 100.00, 125.00, 75.00 ])

      expect(amount.bonus.amount_used).to eq(125.00)
    end
  end

  describe '#remaining_amount' do
    let(:amounts1) { [ 10.0, 20.0, 45.0 ] }
    let(:amounts2) { [ 12.0, 27.0, 13.0 ] }

    it 'calculates using other bonuses for product' do
      product = create(:product, bonus_volume: 666.00)
      bonus = create(:bonus, product: product)
      create(:bonus_amount, bonus: bonus, amounts: amounts1)
      bonus = create(:bonus, product: product)
      create(:bonus_amount, bonus: bonus, amounts: amounts2)

      bonus = create(:bonus, product: product)
      expected = product.commission_amount - (amounts1.max + amounts2.max)
      expect(bonus.remaining_amount).to eq(expected)
    end
  end

end

  # describe '#percentages_used' do

  #   it 'returns the correct value with 1 path' do
  #     bonus = create(:direct_sales_bonus)
  #     create(:bonus_level,
  #            bonus:     bonus,
  #            level:     0,
  #            rank_path: @path1,
  #            amounts:   [ 0.1, 0.2, 0.4 ])

  #     expect(bonus.percentages_used(@max_rank)).to eq([ 0.1, 0.2, 0.4 ])
  #   end

  #   it 'returns the correct value with 2 paths' do
  #     path2 = create(:rank_path)
  #     bonus = create(:direct_sales_bonus)
  #     create(:bonus_level,
  #            bonus:     bonus,
  #            level:     0,
  #            rank_path: @path1,
  #            amounts:   [ 0.1, 0.2, 0.4 ])
  #     create(:bonus_level,
  #            bonus:     bonus,
  #            level:     0,
  #            rank_path: path2,
  #            amounts:   [ 0.2, 0.1, 0.5 ])

  #     expect(bonus.percentages_used(@max_rank)).to eq([ 0.2, 0.2, 0.5 ])

  #     bonus = create(:direct_sales_bonus)
  #     expect(bonus.remaining_percentages(@max_rank)).to eq([ 0.8, 0.8, 0.5 ])
  #   end

  #   it 'returns the correct values for enroller bonus' do
  #     bonus = create(:enroller_bonus)
  #     create(:bonus_level,
  #            bonus:     bonus,
  #            level:     0,
  #            rank_path: @path1,
  #            amounts:   [ 0.0, 0.2, 0.3 ])

  #     expect(bonus.percentages_used(@max_rank)).to eq([ 0.3, 0.0, 0.0 ])
  #   end

  #   it 'returns the correct values for unilevel bonus' do
  #     bonus = create(:unilevel_bonus)
  #     create(:bonus_level,
  #            bonus:     bonus,
  #            level:     1,
  #            rank_path: @path1,
  #            amounts:   [ 0.0, 0.0, 0.1 ])
  #     create(:bonus_level,
  #            bonus:     bonus,
  #            level:     2,
  #            rank_path: @path1,
  #            amounts:   [ 0.0, 0.2, 0.2 ])
  #     create(:bonus_level,
  #            bonus:     bonus,
  #            level:     3,
  #            rank_path: @path1,
  #            amounts:   [ 0.1, 0.1, 0.1 ])

  #     expect(bonus.percentages_used(@max_rank)).to eq([ 0.1, 0.3, 0.4 ])
  #     expect(bonus.remaining_percentages_for_level(2, @max_rank))
  #       .to eq([ 0.9, 0.9, 0.8 ])
  #     expect(bonus.remaining_percentages(@max_rank)).to eq([ 0.9, 0.7, 0.6 ])

  #     bonus = create(:direct_sales_bonus)
  #     expect(bonus.remaining_percentages(@max_rank)).to eq([ 0.9, 0.7, 0.6 ])
  #   end
  # end

