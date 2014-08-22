require 'spec_helper'

describe '/a/pay_periods' do

  before :each do
    login_user

  end

  describe 'GET /' do

    it 'returns a list of pay periods' do
      create(:order, order_date: Date.current - 1.month)

      get pay_periods_path, format: :json

      expect_entities_count(5)
    end

  end

  describe 'POST /:id/calculate' do

    it 'runs a pay period calculation' do
      create(:order, order_date: Date.current - 1.month)
      PayPeriod.generate_missing

      get pay_periods_path, format: :json
      pay_period = json_body['entities'].first
      id = pay_period['properties']['id']

      post calculate_pay_period_path(id), format: :json

      expect_classes('pay_period')
      expect_props(calculated: true)
    end

  end
end
