require 'spec_helper'

describe EnrollerSalesBonus, type: :model do

  before :each do
    create_list(:rank, 3)
  end

  describe '#create_payments!' do

    it 'generates the correct payment' do
      product = create(:product, bonus_volume: 500, commission_percentage: 80)
      bonus = create(:enroller_sales_bonus,
                     max_user_rank_id:   1,
                     min_upline_rank_id: 2)
      create(:bonus_requirement, product: product, bonus: bonus)
      create(:bonus_level, bonus: bonus, amounts: [ 0.0, 0.0 ])

      parent = create(:user, organic_rank: 2)
      user = create(:user, sponsor: parent)
      order = create(:order, product: product, user: user)

      bonus.create_payments!(order, order.monthly_pay_period)
      payment = BonusPayment.where(bonus_id: bonus.id).first

      expect(payment).to_not be_nil
      expect(payment.user_id).to eq(parent.id)
    end

  end

  describe '#percentage_used' do

    it 'accounts for max_user_id with direct sales bonus' do
      product = create(:product, bonus_volume: 500, commission_percentage: 80)

      bonus = create(:direct_sales_bonus)
      create(:bonus_requirement, product: product, bonus: bonus)
      create(:bonus_level, bonus: bonus, amounts: [ 0.1, 0.2, 0.2 ])

      bonus = create(:enroller_sales_bonus, max_user_rank_id: 1)
      create(:bonus_requirement, product: product, bonus: bonus)

      expect(bonus.percentage_used).to eq(0.1)
      expect(bonus.remaining_amount).to eq(360)
    end
  end

end
