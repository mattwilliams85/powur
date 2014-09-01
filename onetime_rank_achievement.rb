class RankAchievement < ActiveRecord::Base

  belongs_to :rank
  belongs_to :user
end
