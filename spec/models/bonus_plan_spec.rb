require 'spec_helper'

describe BonusPlan, type: :model do

  describe '#start_year,#start_month' do
    it 'allows multiple null values on nullable
        columns that have a unique index' do
      create_list(:bonus_plan, 2, start_year: nil, start_month: nil)
    end

    it 'does not allow violation of the unique index' do
      create(:bonus_plan, start_year: 2014, start_month: 11)
      expect { create(:bonus_plan, start_year: 2014, start_month: 11) }
        .to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  describe '#active' do

    before do
      DatabaseCleaner.clean
      @year = DateTime.current.year
      @month = DateTime.current.month
    end

    it 'returns true if the plan is the one with the latest start date' do
      past_plan = create(:bonus_plan,
                         start_year: @year, start_month: @month - 4)
      current_plan = create(:bonus_plan,
                            start_year: @year, start_month: @month - 2)
      future_plan = create(:bonus_plan,
                           start_year: @year + 1, start_month: @month)

      expect(past_plan.active?).to_not be
      expect(current_plan.active?).to be
      expect(future_plan.active?).to_not be
    end

  end
end
