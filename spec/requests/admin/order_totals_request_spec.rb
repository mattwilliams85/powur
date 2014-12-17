require 'spec_helper'

describe 'order totals', type: :request do

  before do
    DatabaseCleaner.clean
    login_user
  end

  def create_pay_period(date)
    MonthlyPayPeriod.find_or_create_by_date(date)
  end

  describe '/a/pay_periods/:id/order_totals' do
    before do
      @pay_period = create_pay_period(DateTime.current - 1.month)
    end

    it 'returns a list of order totals for the pay period' do
      create_list(:order_total, 3, pay_period: @pay_period)
      different_pay_period = create_pay_period(DateTime.current - 2.months)
      create(:order_total, pay_period: different_pay_period)

      get pay_period_order_totals_path(@pay_period), format: :json

      expect_entities_count(3)
    end

    it 'pages order totals' do
      create_list(:order_total, 5, pay_period: @pay_period)

      get pay_period_order_totals_path(@pay_period), format: :json, limit: 3
      expect_entities_count(3)

      get pay_period_order_totals_path(@pay_period),
          format: :json, limit: 3, page: 2
      expect_entities_count(2)
    end

    it 'uses a secondary sort on id' do
      users = create_list(:user, 5, last_name: 'aaaa', first_name: 'bbbb')
      totals = users.map do |u|
        create(:order_total, id: rand(1000...100_000),
               pay_period: @pay_period, user: u)
      end

      get pay_period_order_totals_path(@pay_period), format: :json

      result = json_body['entities'].map { |e| e['properties']['id'] }
      expected = totals.sort_by(&:id).map(&:id)

      expect(result).to eq(expected)
    end

  end

  describe '/a/users/:id/order_totals' do

    before :each do
      @user = create(:user)
    end

    it 'returns a list of order totals for the user' do
      create_list(:order_total, 3, user: @user)
      create(:order_total)

      get admin_user_order_totals_path(@user), format: :json

      expect_entities_count(3)
    end

    it 'sorts order totals' do
      [ 3, 8, 5 ].each { |i| create(:order_total, user: @user, personal: i) }

      get admin_user_order_totals_path(@user), format: :json, sort: :personal

      result = json_body['entities'].map { |e| e['properties']['personal'] }

      expect(result).to eq([ 8, 5, 3 ])
    end
  end
end
