require 'spec_helper'

describe WeeklyPayPeriod, type: :model do

  describe '::ids_from' do

    it 'returns an empty array if the date is within the current week' do
      ids = WeeklyPayPeriod.ids_from(Date.current - 1.minute)
      expect(ids).to be_empty
    end

    it 'returns last weeks id if first order is a month ago' do
      from = Date.current - 1.week
      ids = WeeklyPayPeriod.ids_from(from)
      expect(ids.size).to eq(1)
      expect(ids.first).to eq(from.strftime('%GW%V'))
    end

    it 'works across years' do
      from = Date.current - 1.year
      ids = WeeklyPayPeriod.ids_from(from)
      expect(ids.size).to eq(52)
    end

  end

  describe '::create_from_id' do

    it 'creates a new pay period from an id value' do
      id = '2014W34'
      pay_period = WeeklyPayPeriod.create_from_id(id)

      expected = Date.parse(id)
      expect(pay_period.start_date).to eq(expected)
      expect(pay_period.end_date).to eq(expected.end_of_week)
      expect(pay_period.calculated?).to_not be
    end

  end
end
