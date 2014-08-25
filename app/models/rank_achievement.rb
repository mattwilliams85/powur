class RankAchievement < ActiveRecord::Base

  belongs_to :pay_period
  belongs_to :user
  belongs_to :path
end
