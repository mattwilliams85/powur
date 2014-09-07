require 'spec_helper'

describe MonthlyPayPeriod, type: :model do

  describe '::ids_from' do

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

  describe '::find_or_create_by_id' do

    it 'creates a new pay period from an id value' do
      id = '2014-08'
      pay_period = MonthlyPayPeriod.find_or_create_by_id(id)

      expected = Date.new(2014, 8, 1)
      expect(pay_period.start_date).to eq(expected)
      expect(pay_period.end_date).to eq(expected.end_of_month)
      expect(pay_period.calculated?).to_not be
    end

  end

end
