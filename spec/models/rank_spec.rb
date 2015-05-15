require 'spec_helper'

describe Rank, type: :model do

  it 'groups qualifications by rank path' do
    rank = create(:rank)

    path1 = create(:rank_path)
    path2 = create(:rank_path)
    create(:group_sales_qualification, rank_path: path1, rank: rank)
    create_list(:sales_qualification, 2, rank_path: path2, rank: rank)

    expect(rank.qualifiers(path1.id).size).to eq(1)
    expect(rank.qualifiers(path2.id).size).to eq(2)


    create(:sales_qualification, rank_path: nil, rank: rank)
    rank = Rank.find(rank.id)
    expect(rank.qualifiers(path1.id).size).to eq(2)
    expect(rank.qualifiers(path2.id).size).to eq(3)
  end
end
