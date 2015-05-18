require 'spec_helper'

describe 'earnings', type: :request do
  before :each do
    login_user(auth: true)
  end

  let(:pp1) do
    create(:weekly_pay_period, start_date: DateTime.current - 1.year)
  end

  let(:pp2) do
    create(:weekly_pay_period, start_date: DateTime.current - 6.months)
  end

  let(:pp3) do
    create(:weekly_pay_period, start_date: DateTime.current - 3.months)
  end

  let(:pp4) do
    create(:weekly_pay_period, start_date: DateTime.current - 4 .months)
  end

  let(:range_start) { DateTime.current - 10.months }
  let(:range_end) { DateTime.current }
  let(:params) do
    { start_month: range_start.month,
      start_year:  range_start.year,
      end_month:   range_end.month,
      end_year:    range_end.year,
      user_id:     @user.id }
  end

  describe '/u/earnings/summary' do
    it 'returns a list of earnings for the user, grouped by pay_period' do
      create(:rank)
      create(:bonus_payment, pay_period: pp1, user_id: @user.id)
      create(:bonus_payment, pay_period: pp2, user_id: @user.id)
      create(:bonus_payment, pay_period: pp2, user_id: @user.id)
      create(:bonus_payment, pay_period: pp2, user_id: @user.id)
      create(:bonus_payment, pay_period: pp3, user_id: @user.id)

      get summary_earnings_path(params), format: :json
      expect_entities_count(2)
    end
  end

  describe '/u/earnings/detail' do
    it 'returns the earning details for a user\s bonus payment' do
      create(:rank)
      pp = create(:weekly_pay_period, start_date: DateTime.current - 1.week)
      create(:bonus_payment, pay_period: pp, user_id: @user.id)
      create(:bonus_payment, pay_period: pp, user_id: @user.id)

      get detail_earnings_path(pay_period_id: pp.id,
                               user_id:       @user.id), format: :json
      expect_entities_count(2)
      expect_classes 'earning_details'
    end
  end
end