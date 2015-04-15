require 'spec_helper'

describe '/a/pay_periods' do

  before do
    login_user
  end

  describe 'GET /' do

    it 'returns a list of pay periods' do
      create(:order, order_date: Date.current - 1.month)

      get pay_periods_path, format: :json

      expect_entities_count(5)
    end

    it 'filters by calculated' do
      create(:weekly_pay_period, calculated_at: nil)
      pay_period = create(:monthly_pay_period)

      get pay_periods_path, calculated: 'true', format: :json

      expect_entities_count(1)
      result = json_body['entities'].first
      expect(result['properties']['id']).to eq(pay_period.id)
    end

  end

  describe 'GET /:id' do

    it 'returns the details of the pay period' do
      create(:rank)
      order = create(:order, order_date: Date.current - 1.month)
      order.monthly_pay_period.touch :calculated_at
      pay_period = order.monthly_pay_period
      create_list(:order_total, 3, pay_period: pay_period)
      create_list(:bonus_payment, 3, pay_period: pay_period)

      get pay_period_path(pay_period), format: :json

      expect(json_body['properties']['totals']).to_not be_nil
      expect_entities 'pay_period-order_totals', 'pay_period-rank_achievements'
    end

  end

  describe 'POST /:id/calculate' do

    it 'runs a pay period calculation' do
      create(:order, order_date: Date.current - 1.month)
      PayPeriod.generate_missing

      get pay_periods_path, format: :json
      pay_period = json_body['entities'].last
      id = pay_period['properties']['id']

      post calculate_pay_period_path(id), format: :json

      expect_classes('pay_periods')
      pay_period = json_body['entities'].last
      expect(pay_period['properties']['calculated']).to be
    end

  end

  describe 'POST /:id/recalculate' do

    it 'recalcs a pay period' do
      order = create(:order, order_date: Date.current - 1.month)
      pay_period = order.weekly_pay_period
      pay_period.calculate!

      post recalculate_pay_period_path(pay_period.id), format: :json
    end
  end

  # describe 'POST /:id/distribute' do

  #   it 'distributes totaled bonus amounts to users for a pay period' do
  #     pay_period = create(:monthly_pay_period)
  #     create_list(:bonus_payment, 5, pay_period: pay_period, amount: 50.00)

  #     get pay_periods_path, format: :json
  #     pay_period = json_body['entities'].last
  #     id = pay_period['properties']['id']

  #     post distribute_pay_period_path(id), format: :json

  #     expect_classes('pay_periods')
  #     pay_period = json_body['entities'].last
  #     expect(pay_period['properties']['distributed']).to be
  #   end
  # end

end
