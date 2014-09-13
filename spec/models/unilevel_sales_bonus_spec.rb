require 'spec_helper'

describe UnilevelSalesBonus, type: :model do

  before :each do
    create_list(:rank, 3)
  end

  describe '#create_payments!' do

    it 'generates the correct bonus payments' do
      product = create(:product, bonus_volume: 500, commission_percentage: 80)
      bonus = create(:unilevel_sales_bonus, compress: true)
      create(:bonus_requirement, product: product, bonus: bonus)
      create(:bonus_level, level: 1, bonus: bonus, amounts: [ 0.1, 0.1, 0.1, 0.1 ])
      create(:bonus_level, level: 2, bonus: bonus, amounts: [ 0.0, 0.05, 0.05, 0.05 ])
      create(:bonus_level, level: 3, bonus: bonus, amounts: [ 0.0, 0.0, 0.01, 0.01 ])

      parent1 = create(:user, organic_rank: 3)
      parent2 = create(:user, sponsor: parent1)
      parent3 = create(:user, sponsor: parent2, organic_rank: 2)
      parent4 = create(:user, sponsor: parent3)
      user = create(:user, sponsor: parent4)

      order = create(:order, product: product, user: user)

      bonus.create_payments!(order, order.monthly_pay_period)

      payment = BonusPayment.where(user_id: parent1.id).first
      expect(payment).to_not be_nil
      expect(payment.amount).to eq(4.0)

      payment = BonusPayment.where(user_id: parent2.id).first
      expect(payment).to be_nil

      payment = BonusPayment.where(user_id: parent3.id).first
      expect(payment).to_not be_nil
      expect(payment.amount).to eq(20.0)

      payment = BonusPayment.where(user_id: parent4.id).first
      expect(payment).to_not be_nil
      expect(payment.amount).to eq(40.0)
    end

  end

end
