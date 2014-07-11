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
end