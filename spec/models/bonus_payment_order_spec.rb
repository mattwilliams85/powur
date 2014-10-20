require 'spec_helper'

describe BonusPaymentOrder, type: :model do

  describe '::for_pay_period' do

    it 'selects by pay period' do
      pp1 = create(:weekly_pay_period, at: DateTime.current - 3.months)
      pp2 = create(:weekly_pay_period, at: DateTime.current - 1.month)
      payment = create(:bonus_payment, pay_period: pp1)
      create(:bonus_payment_order, bonus_payment: payment)
      payment = create(:bonus_payment, pay_period: pp1)
      create(:bonus_payment_order, bonus_payment: payment)
      payment = create(:bonus_payment, pay_period: pp2)
      create(:bonus_payment_order, bonus_payment: payment)

      result = BonusPaymentOrder.for_pay_period(pp1.id).entries
      expect(result.size).to eq(2)
      result.each do |record|
        expect(record.bonus_payment.pay_period_id).to eq(pp1.id)
      end

      result = BonusPaymentOrder.for_pay_period(pp2.id).entries
      expect(result.size).to eq(1)

      BonusPaymentOrder.delete_all_for_pay_period(pp1.id)
      expect(BonusPaymentOrder.count).to eq(1)
      expect(BonusPaymentOrder.first.bonus_payment.pay_period_id).to eq(pp2.id)
    end
  end
end
