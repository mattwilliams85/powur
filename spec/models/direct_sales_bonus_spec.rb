require 'spec_helper'

describe DirectSalesBonus, type: :model do

  before :each do
    create_list(:rank, 3)
  end

  it 'returns the correct amount' do
    product = create(:product, bonus_volume: 500, commission_percentage: 80)
    bonus = create(:direct_sales_bonus)
    create(:bonus_level, bonus: bonus, amounts: [ 0.125, 0.375, 0.6 ])

    expect(bonus.payment_amount(1, nil)).to eq(50)
    expect(bonus.payment_amount(2, nil)).to eq(150)
    expect(bonus.payment_amount(3, nil)).to eq(240)
    expect(bonus.payment_amount(4, nil)).to eq(0)
  end

end
