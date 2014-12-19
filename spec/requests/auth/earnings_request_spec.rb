require 'spec_helper'

describe 'earnings', type: :request do

  before :each do
    login_user
  end

  describe '/u/earnings/summary' do
    it 'returns a list of earnings for the user, grouped by pay_period' do
      user = create(:user)
      pp1 = create(:weekly_pay_period, at: DateTime.current - 1.year)
      pp2 = create(:weekly_pay_period, at: DateTime.current - 6.months)
      pp3 = create(:weekly_pay_period, at: DateTime.current - 3.months)
      create(:bonus_payment, pay_period: pp1, user_id: user.id)
      create(:bonus_payment, pay_period: pp2, user_id: user.id)
      create(:bonus_payment, pay_period: pp2, user_id: user.id)
      create(:bonus_payment, pay_period: pp2, user_id: user.id)
      create(:bonus_payment, pay_period: pp3, user_id: user.id)

      range_start = DateTime.current - 10.months
      range_end = DateTime.current
      params = { start_month: range_start.month,
                 start_year:  range_start.year,
                 end_month:   range_end.month,
                 end_year:    range_end.year,
                 user_id:     user.id
                }

      get summary_earnings_path(params), format: :json
      expect_entities_count(2)
    end
  end
end
