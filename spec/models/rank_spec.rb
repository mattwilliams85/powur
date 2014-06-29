require 'spec_helper'

describe Rank, type: :model do


  it 'creates a qualification' do
    rank = create(:rank)

    qualification = rank.qualifications.
      create!(type: CertificationQualification.name, name: 'Foo')

    expect(qualification).to be_instance_of(CertificationQualification)
  end
end