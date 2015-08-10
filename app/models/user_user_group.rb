class UserUserGroup < ActiveRecord::Base
  self.primary_keys = :user_id, :user_group_id

  belongs_to :user
  belongs_to :user_group

  validates_presence_of :user_id, :user_group_id

  scope :highest_ranks, lambda { |user_id: nil, pay_period_id: nil|
    query = select('max(rank_id) highest_rank, user_id')
      .joins(user_group: :ranks_user_groups)
      .group('user_user_groups.user_id')
    query = query.where('user_user_groups.user_id' => user_id) if user_id
    query = query.where(pay_period_id: pay_period_id) if pay_period_id
    query
  }

  class << self
    def populate(pay_period_id)
      ranks = Rank.preloaded.select { |r| !r.requirements.empty? }.entries
      previous_rank = ranks.first
      results = previous_rank.join_qualified(pay_period_id)

      ranks[1..-1].each do |rank|
        results = rank.join_qualified(rank, previous_rank)
        # break if results.empty?
        previous_rank = rank
      end
    end

    def populate_all!(pp_ids = nil)
      pp_ids ||= MonthlyPayPeriod.relevant_ids << MonthlyPayPeriod.current_id
      pp_ids.each { |pp_id| populate(pp_id) }
    end
  end
end
