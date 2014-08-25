require 'spec_helper'

describe 'order totals', type: :request do

  before :each do
    login_user
  end

  def create_pay_period(date)
    MonthlyPayPeriod.find_or_create_by_date(date)
  end

  describe '/a/pay_periods/:id/order_totals' do

    it 'returns a list of order totals for the pay period' do
      pay_period = create_pay_period(DateTime.current - 1.month)

      create_list(:order_total, 3, pay_period: pay_period)
      create(:order_total, 
        pay_period: create_pay_period(DateTime.current - 2.months))

      get pay_period_order_totals_path(pay_period), format: :json

      expect_entities_count(3)
    end

  end

  describe '/a/users/:id/order_totals' do

    it 'returns a list of order totals for the user' do
      user = create(:user)

      create_list(:order_total, 3, user: user)
      create(:order_total)

      get admin_user_order_totals_path(user), format: :json

      expect_entities_count(3)
    end
  end
end
