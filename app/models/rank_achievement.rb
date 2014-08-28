class RankAchievement < ActiveRecord::Base

  belongs_to :pay_period
  belongs_to :user
end
