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


    end

  end

end
