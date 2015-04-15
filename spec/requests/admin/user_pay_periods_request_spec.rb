require 'spec_helper'

describe '/u/users/:admin_user_id/pay_periods' do

  before do
    login_user
  end

  describe 'GET /' do

    it 'returns the pay periods the user has been active for' do
      user = create(:user, created_at: 1.month.ago)
      create(:order, order_date: 2.months.ago)

      get admin_user_pay_periods_path(user), format: :json
      expect(json_body['entities'].size).to be < PayPeriod.count
    end

  end

  describe 'GET /:id' do

    it 'includes the bonus totals by bonus type' do
      create(:rank)
      user = create(:user)
      pay_period = create(:monthly_pay_period)
      create(:order_total, pay_period: pay_period, user: user)
      bonus = create(:seller_bonus)
      create_list(:bonus_payment, 5,
                  user:       user,
                  bonus:      bonus,
                  pay_period: pay_period)

      get admin_user_pay_period_path(user, pay_period), format: :json
    end
  end

end
