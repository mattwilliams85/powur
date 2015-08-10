class UserRank < ActiveRecord::Base
  self.primary_keys = :user_id, :rank_id, :pay_period_id

  belongs_to :user
  belongs_to :rank
  belongs_to :pay_period

  validates_presence_of :user_id, :rank_id, :pay_period_id

  scope :highest_ranks, lambda { |pay_period_id: nil|
    query = select('max(user_ranks.rank_id) rank_id, user_ranks.user_id')
      .group(:user_id)
    query = query.where(pay_period_id: pay_period_id) if pay_period_id
    query
  }

  scope :highest_lifetime_ranks, lambda {
    join = Rank.lifetime_requirements.to_sql
    highest_ranks.joins("INNER JOIN (#{join}) lr ON lr.id = user_ranks.rank_id")
  }
end
