require 'spec_helper'

describe Rank, type: :model do

  it 'nullifies associated bonus field values' do
    rank = create(:rank)
    bonus = create(:enroller_sales_bonus,
                   max_user_rank:   rank,
                   min_upline_rank: rank,
                   achieved_rank:   rank)

    rank.destroy

    bonus.reload
    expect(bonus.max_user_rank_id).to_not be
    expect(bonus.min_upline_rank_id).to_not be
    expect(bonus.achieved_rank_id).to_not be
  end

  it 'groups qualifications by rank path' do
    rank = create(:rank)

    path1 = create(:rank_path)
    path2 = create(:rank_path)
    create(:group_sales_qualification, rank_path: path1, rank: rank)
    create_list(:sales_qualification, 2, rank_path: path2, rank: rank)

    expect(rank.qualification_paths.size).to eq(2)
    expect(rank.grouped_qualifications[path1].size).to eq(1)
    expect(rank.grouped_qualifications[path2].size).to eq(2)
  end
end
