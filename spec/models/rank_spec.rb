require 'spec_helper'

describe Rank, type: :model do

  it 'creates a qualification' do
    rank = create(:rank)

    qualification = rank.qualifications.create!(
      type: SalesQualification.name, 
      product: create(:product),
      quantity: 3,
      period: :lifetime)

    expect(qualification).to be_instance_of(SalesQualification)
  end

  it 'nullifies associated bonus field values' do
    rank = create(:rank)
    bonus = create(:enroller_sales_bonus, 
                    max_user_rank: rank,
                    min_upline_rank: rank,
                    achieved_rank: rank)

    rank.destroy

    bonus.reload
    expect(bonus.max_user_rank_id).to_not be
    expect(bonus.min_upline_rank_id).to_not be
    expect(bonus.achieved_rank_id).to_not be
  end
end