require 'spec_helper'

describe MonthlyPayPeriod, type: :model do

  describe '::ids_from' do

    it 'returns an empty array if the date is within the current month' do
      ids = MonthlyPayPeriod.ids_from(Date.current - 1.minute)
      expect(ids).to be_empty
    end

    it 'returns last months id if first order is a month ago' do
      from = Date.current - 1.month
      ids = MonthlyPayPeriod.ids_from(from)
      expect(ids.size).to eq(1)
      expect(ids.first).to eq(from.strftime('%Y-%m'))
    end

    it 'works across years' do
      from = Date.current - 1.year
      ids = MonthlyPayPeriod.ids_from(from)
      expect(ids.size).to eq(12)
    end

  end

  describe '::create_from_id' do

    it 'creates a new pay period from an id value' do
      id = '2014-08'
      pay_period = MonthlyPayPeriod.create_from_id(id)

      expected = Date.new(2014, 8, 1)
      expect(pay_period.start_date).to eq(expected)
      expect(pay_period.end_date).to eq(expected.end_of_month)
      expect(pay_period.calculated?).to_not be
    end

  end
end
