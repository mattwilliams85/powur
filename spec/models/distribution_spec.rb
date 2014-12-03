require 'spec_helper'

describe Distribution, type: :model do

  describe '#save a distribution record!' do
    it 'stores a record in the database for users by pay period' do
      user = create(:user)
      pay_period1 = MonthlyPayPeriod
                    .find_or_create_by_date(DateTime.now - 2.months)
      pay_period2 = MonthlyPayPeriod
                    .find_or_create_by_date(DateTime.now - 4.months)
      amount1 = BigDecimal('138.3413')
      amount2 = BigDecimal('14.23')
      Distribution.create(pay_period_id: pay_period1.id,
                          user_id: user.id, amount: amount1)
      Distribution.create(pay_period_id: pay_period2.id,
                          user_id: user.id, amount: amount2)

      distributions = Distribution.where(user_id:       user.id,
                                         pay_period_id: pay_period1.id)
      expect(distributions.size).to eq(1)
    end
  end
end
