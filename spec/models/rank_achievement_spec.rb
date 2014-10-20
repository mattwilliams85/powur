require 'spec_helper'

describe RankAchievement, type: :model do

  before :each do
    create_list(:rank, 2)
  end

  it 'does not allow two lifetime rank achievements' do
    achievement = create(:rank_achievement, pay_period: nil, rank_id: 2)
    expect do
      create(:rank_achievement,
             pay_period: nil,
             rank_id:    2,
             user:       achievement.user)
    end.to raise_error(ActiveRecord::RecordNotUnique)
  end

end
