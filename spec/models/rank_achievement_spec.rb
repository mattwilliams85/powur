require 'spec_helper'

describe RankAchievement, type: :model do

  before :each do
    create_list(:rank, 2)
  end

  it 'does not allow two lifetime rank achievements' do
    path = create(:rank_path)
    achievement = create(:rank_achievement,
                         pay_period: nil,
                         rank_id:    2,
                         rank_path:  path)
    expect do
      create(:rank_achievement,
             pay_period: nil,
             rank_id:    2,
             rank_path:  path,
             user:       achievement.user)
    end.to raise_error(ActiveRecord::RecordNotUnique)
  end

end
