require 'spec_helper'

describe 'bonus payments', type: :request do

  before do
    DatabaseCleaner.clean
    login_user
  end

  describe '/a/pay_periods/:id/bonus_payments' do
    it 'pages a list for the pay period' do
      pay_period = create(:monthly_pay_period)
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

    it 'filters by bonus' do
      pay_period = create(:monthly_pay_period)
      bonus1 = create(:enroller_bonus)
      bonus2 = create(:unilevel_bonus)
      create(:bonus_payment, pay_period: pay_period, bonus: bonus1)
      create(:bonus_payment, pay_period: pay_period, bonus: bonus2)

      get pay_period_bonus_payments_path(pay_period),
          bonus: bonus1.id, format: :json

      expect_entities_count(1)
      result = json_body['entities'].first['properties']['name']
      expect(result).to eq(bonus1.name)
    end
  end

  describe '/a/users/:id/bonus_payments' do
    before :each do
      @money_user = create(:user)
      @bonus_payments = []
      @pay_periods = [ 2, 3, 1 ].map do |i|
        pay_period = create(:weekly_pay_period, start_date: DateTime.current - i.weeks)
        @bonus_payments << create(:bonus_payment,
                                  pay_period: pay_period,
                                  user:       @money_user)
        pay_period
      end
    end

    it 'defaults the pay period' do
      get admin_user_bonus_payments_path(@money_user), format: :json

      result = json_body['properties']['filters']['pay_period']
      expect(result).to eq(PayPeriod.last_id)
    end

    it 'filters bonus payments by pay period' do
      get admin_user_bonus_payments_path(@money_user),
          format: :json, pay_period: @pay_periods.first.id

      expect_entities_count(1)
      result = json_body['entities'].first['properties']['pay_period_id']
      expect(result).to eq(@pay_periods.first.id)
    end

    it 'filters bonus payments by bonus' do
      bonus_id = @bonus_payments.first.bonus_id
      get admin_user_bonus_payments_path(@money_user),
          format: :json, bonus: bonus_id, pay_period: @pay_periods.first.id

      expect_entities_count 1
    end
  end

  describe '/a/orders/:admin_order_id/bonus_payments' do
    it 'returns bonus payments associated with an order' do
      pay_period = create(:weekly_pay_period, start_date: DateTime.current - 1.month)
      order = create(:order)

      [ :direct_sales_bonus, :enroller_bonus ].each do |bonus_type|
        bonus_payment = create(:bonus_payment,
                               bonus:      create(bonus_type),
                               pay_period: pay_period)
        create(:bonus_payment_order,
               order:         order,
               bonus_payment: bonus_payment)
      end
      bonus = create(:unilevel_bonus)
      create_list(:bonus_payment, 3,
                  bonus:      bonus,
                  pay_period: pay_period).each do |bp|
        create(:bonus_payment_order,
               order:         order,
               bonus_payment: bp)
      end

      get admin_order_bonus_payments_path(order), format: :json

      expect_entities_count(5)
    end
  end
end
