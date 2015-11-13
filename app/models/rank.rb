class Rank < ActiveRecord::Base
  has_many :requirements, class_name: 'RankRequirement'
  has_many :user_ranks, dependent: :destroy
  has_many :users, through: :user_ranks
  has_many :lifetime_rank_users,
           class_name:  'User',
           foreign_key: :lifetime_rank,
           dependent:   :nullify
  has_many :organic_rank_users,
           class_name:  'User',
           foreign_key: :organic_rank,
           dependent:   :nullify

  default_scope -> { order(:id) }
  validates_presence_of :title

  scope :preloaded, -> { preload(:requirements) }
  scope :lifetime_requirements, lambda {
    join = RankRequirement.monthly_join.to_sql
    joins("LEFT JOIN (#{join}) r ON r.rank_id = ranks.id")
      .where('r.rank_id IS NULL')
  }
  scope :monthly_requirements, lambda {
    join = RankRequirement.monthly_join.to_sql
    joins("INNER JOIN (#{join}) r ON r.rank_id = ranks.id")
  }

  before_create do
    self.id ||= Rank.count + SystemSettings.min_rank
  end

  def first?
    @first.nil? ? (@first = (id == Rank.minimum(:id))) : @first
  end

  def last?
    @last.nil? ? (@last = (id == Rank.maximum(:id))) : @last
  end

  def newly_qualified_user_ids(pay_period_id)
    only_users = previous_user_ranks(pay_period_id) if id > 1
    existing_users = user_ranks.where(pay_period_id: pay_period_id)

    requirements.map do |req|
      req.qualified_user_ids(
        pay_period_id: pay_period_id,
        include_users: only_users,
        exclude_users: existing_users)
    end.inject(:&)
  end

  def rank_users(pay_period_id)
    attrs = newly_qualified_user_ids(pay_period_id).map do |user_id|
      { user_id: user_id, pay_period_id: pay_period_id }
    end
    user_ranks.create!(attrs)
  end

  def rank_user(user_id, pay_period_id)
    attrs = { user_id: user_id, pay_period_id: pay_period_id }
    
    if user_ranks.where(attrs).exists? ||
        !user_qualified?(user_id, pay_period_id)
      return
    end
    
    user_ranks.create!(attrs)
  end

  def requirements?
    requirements.size.zero?
  end

  private

  def previous_user_ranks(pay_period_id)
    UserRank.where(rank_id: id - 1, pay_period_id: pay_period_id)
  end

  def user_qualified?(user_id, pay_period_id)
    requirements.all? { |r| r.user_qualified?(user_id, pay_period_id) }
  end

  class << self
    def from_attrs(attrs)
      id = attrs.delete('id').to_i
      requirements = attrs.delete('requirements')
      rank = Rank.where(id: id).first
      if rank
        rank.update_attributes!(attrs)
      else
        rank = Rank.create!(attrs)
      end

      rank.requirements.destroy_all
      if requirements
        requirements.each { |req_attrs| rank.requirements.create!(req_attrs) }
      end

      rank
    end

    def rank_range
      return nil unless Rank.count > 0
      (Rank.order(:id).first.id..Rank.order(:id).last.id)
    end

    def find_or_create_by_id(id)
      find_or_create_by(id: id) do |rank|
        rank.title = "Rank #{id}"
      end
    rescue ActiveRecord::RecordNotUnique
      retry
    end

    def rank_users(*pay_period_ids)
      if pay_period_ids.empty?
        pay_period_ids = MonthlyPayPeriod.relevant_ids(current: true)
      end

      ranks = preloaded.select { |r| !r.requirements? }.entries
      pay_period_ids.each do |pay_period_id|
        ranks.each { |rank| rank.rank_users(pay_period_id) }
      end
      User.update_organic_ranks
      User.update_lifetime_ranks
    end

    def rank_user(user_id)
      pay_period = MonthlyPayPeriod.current

      rank_at = UserRank.where(
        user_id:       user_id,
        pay_period_id: pay_period.id).maximum(:rank_id) || 0
      ranks = preloaded.where('id > ?', rank_at).select { |r| !r.requirements? }
      ranks.each { |rank| rank.rank_user(user_id, pay_period.id) }
      User.update_organic_ranks
      User.update_lifetime_ranks
    end

    def rank_users!
      UserRank.delete_all
      User.update_all(organic_rank: nil)
      User.update_all(lifetime_rank: nil)
      rank_users
    end
  end
end
