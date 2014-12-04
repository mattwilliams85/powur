require 'spec_helper'

describe FastStartBonus, type: :model do

  it 'does not allow an invalid time period' do
    expect { create(:fast_start_bonus, time_period: 'centuries') }
      .to raise_error(ActiveRecord::RecordInvalid)
  end

  it 'does not all a non integer for time_amount' do
    expect { create(:fast_start_bonus, time_amount: 'foo') }
      .to raise_error(ActiveRecord::RecordInvalid)
  end

  it 'returns an integer for the time_amount property' do
    bonus = create(:fast_start_bonus, time_amount: '2')
    expect(bonus.time_amount_int).to be_a(Fixnum)
  end
end
