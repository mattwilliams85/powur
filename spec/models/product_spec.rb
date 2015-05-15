require 'spec_helper'

describe Product, type: :model do
  let(:product) do
    create(:product, bonus_volume: 1000, commission_percentage: 74)
  end
  let(:bonus1) { create(:bonus, product: product) }
  let(:bonus2) { create(:bonus, product: product) }

  it 'creates a sku' do
    expect(product.sku.size).to eq(7)
  end

  describe '#commission_amount' do
    it 'calculates the commission amount correctly' do
      expect(product.commission_amount).to eq(740.00)
    end
  end

  describe '#commission_used' do
    it 'calculates the commission used correctly' do
      create(:bonus_amount, bonus: bonus1, amounts: [ 120.00, 240.00 ])

      expect(product.commission_used).to eq(240.00)
    end
  end

  describe '#commission_remaining' do
    it 'calculates the commission remaining correctly' do
      create(:bonus_amount, bonus: bonus1, amounts: [ 500.00, 240.00 ])

      expect(product.commission_remaining).to eq(240.00)
    end

    it 'calculates the commission remaining for a bonus correctly' do
      create(:bonus_amount, bonus: bonus1, amounts: [ 500.00, 240.00 ])
      create(:bonus_amount, bonus: bonus2, amounts: [ 120.00, 0.00 ])

      expect(product.commission_remaining(bonus1)).to eq(620.00)
      expect(product.commission_remaining(bonus2)).to eq(240.00)
    end
  end
end
