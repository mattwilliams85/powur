require 'spec_helper'

describe 'order totals', type: :request do

  before :each do
    login_user
  end

  describe '/a/pay_periods/:id/bonus_payments' do

    it 'pages a list for the pay period' do
      pay_period = MonthlyPayPeriod.
        find_or_create_by_date(DateTime.current - 1.month)
      create_list(:bonus_payment, 5, pay_period: pay_period, amount: 50.00)

      get pay_period_bonus_payments_path(pay_period),
        format: :json, limit: 3
      expect_entities_count(3)

      get pay_period_bonus_payments_path(pay_period),
        format: :json, limit: 3, page: 2
      expect_entities_count(2)

      payment = json_body['entities'].first
      expect(payment['properties']['amount']).to eq('$50.00')
    end

  end

  describe '/a/users/:id/bonus_payments' do
    before :each do
      @money_user = create(:user)
      @pay_periods = [ 2, 3, 1 ].map do |i|
        pay_period = WeeklyPayPeriod.
          find_or_create_by_date(DateTime.current - i.weeks)
        create(:bonus_payment, pay_period: pay_period, user: @money_user)
        pay_period
      end

    end

    it 'orders bonus payments by pay period' do
      get admin_user_bonus_payments_path(@money_user), format: :json

      result = json_body['entities'].map { |bp| bp['properties']['pay_period_id'] }
      expect(result).to eq(@pay_periods.map(&:id).sort.reverse)
    end

    it 'filters bonus payments by pay period' do
      get admin_user_bonus_payments_path(@money_user),
        format: :json, pay_period: @pay_periods.first.id

      expect_entities_count(1)
      result = json_body['entities'].first['properties']['pay_period_id']
      expect(result).to eq(@pay_periods.first.id)
    end

  end

end
