require 'spec_helper'

describe PayPeriod, type: :model do

  describe '::generate_missing' do

    it 'backfills missing pay periods' do
      order_date = Date.current - 1.month
      create(:order, order_date: order_date)
      PayPeriod.generate_missing

      periods = MonthlyPayPeriod.all.order(start_date: :desc).entries
      expect(periods.size).to eq(1)
      expect(periods.first.id).to eq(order_date.strftime('%Y-%m'))

      periods = WeeklyPayPeriod.all.order(start_date: :desc).entries
      expect(periods.size).to eq(4)
      expected = (0...4).map { |i| (order_date + i.weeks).strftime('%GW%V') }
      expect(periods.map(&:id).sort).to eq(expected)
    end

  end
end
