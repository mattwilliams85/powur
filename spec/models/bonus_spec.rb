require 'spec_helper'

describe Bonus, type: :model do
  before :each do
    Product.create!(name: 'Solar Item', bonus_volume: 500)
    Rank.create(id: 1, title: 'Advocate')
    @product = create(:product)
    @path1 = create(:rank_path)
    create_list(:rank, 2)
    @max_rank = Rank.count
  end

  describe '#percentages_used' do

    it 'returns the correct value with 1 path' do
      bonus = create(:direct_sales_bonus)
      create(:bonus_requirement, bonus: bonus, product: @product)
      create(:bonus_level,
             bonus:     bonus,
             level:     0,
             rank_path: @path1,
             amounts:   [ 0.1, 0.2, 0.4 ])

      expect(bonus.percentages_used(@max_rank)).to eq([ 0.1, 0.2, 0.4 ])
    end

    it 'returns the correct value with 2 paths' do
      path2 = create(:rank_path)
      bonus = create(:direct_sales_bonus)
      create(:bonus_requirement, bonus: bonus, product: @product)
      create(:bonus_level,
             bonus:     bonus,
             level:     0,
             rank_path: @path1,
             amounts:   [ 0.1, 0.2, 0.4 ])
      create(:bonus_level,
             bonus:     bonus,
             level:     0,
             rank_path: path2,
             amounts:   [ 0.2, 0.1, 0.5 ])

      expect(bonus.percentages_used(@max_rank)).to eq([ 0.2, 0.2, 0.5 ])

      bonus = create(:direct_sales_bonus)
      create(:bonus_requirement, bonus: bonus, product: @product)
      expect(bonus.remaining_percentages(@max_rank)).to eq([ 0.8, 0.8, 0.5 ])
    end

    it 'returns the correct values for enroller bonus' do
      bonus = create(:enroller_bonus)
      create(:bonus_requirement, bonus: bonus, product: @product)
      create(:bonus_level,
             bonus:     bonus,
             level:     0,
             rank_path: @path1,
             amounts:   [ 0.0, 0.2, 0.3 ])

      expect(bonus.percentages_used(@max_rank)).to eq([ 0.3, 0.0, 0.0 ])
    end

    it 'returns the correct values for unilevel bonus' do
      bonus = create(:unilevel_bonus)
      create(:bonus_requirement, bonus: bonus, product: @product)
      create(:bonus_level,
             bonus:     bonus,
             level:     1,
             rank_path: @path1,
             amounts:   [ 0.0, 0.0, 0.1 ])
      create(:bonus_level,
             bonus:     bonus,
             level:     2,
             rank_path: @path1,
             amounts:   [ 0.0, 0.2, 0.2 ])
      create(:bonus_level,
             bonus:     bonus,
             level:     3,
             rank_path: @path1,
             amounts:   [ 0.1, 0.1, 0.1 ])

      expect(bonus.percentages_used(@max_rank)).to eq([ 0.1, 0.3, 0.4 ])
      expect(bonus.remaining_percentages_for_level(2, @max_rank))
        .to eq([ 0.9, 0.9, 0.8 ])
      expect(bonus.remaining_percentages(@max_rank)).to eq([ 0.9, 0.7, 0.6 ])

      bonus = create(:direct_sales_bonus)
      create(:bonus_requirement, bonus: bonus, product: @product)
      expect(bonus.remaining_percentages(@max_rank)).to eq([ 0.9, 0.7, 0.6 ])
    end
  end

end
