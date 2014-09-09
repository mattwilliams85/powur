require 'spec_helper'

describe 'order totals', type: :request do

  before :each do
    login_user
  end

  describe '/a/pay_periods/:id/bonus_payments' do

    it 'pages a list for the pay period' do
      pay_period = MonthlyPayPeriod.
        find_or_create_by_date(DateTime.current - 1.month)
      create_list(:bonus_payment, 5, pay_period: pay_period)

      get pay_period_bonus_payments_path(pay_period),
        format: :json, limit: 3
      expect_entities_count(3)

      get pay_period_bonus_payments_path(pay_period),
        format: :json, limit: 3, page: 2
      expect_entities_count(2)
    end

  end

  describe '/a/users/:id/bonus_payments' do

    it 'orders bonus payments by pay period' do
      user = create(:user)

      pay_periods = [ 2, 3, 1 ].map do |i|
        pay_period = WeeklyPayPeriod.
          find_or_create_by_date(DateTime.current - i.weeks)
        create(:bonus_payment, pay_period: pay_period, user: user)
        pay_period
      end

      get admin_user_bonus_payments_path(user), format: :json

      result = json_body['entities'].map { |bp| bp['properties']['pay_period_id'] }
      expect(result).to eq(pay_periods.map(&:id).sort.reverse)
      binding.pry
    end

  end

end
