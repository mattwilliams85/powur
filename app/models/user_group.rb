class UserGroup < ActiveRecord::Base
  validates :title, presence: true
  validates :id, presence: true, uniqueness: true

  has_many :requirements,
           class_name: 'UserGroupRequirement',
           dependent:  :destroy
  has_many :user_user_groups, dependent: :destroy
  has_many :users, through: :user_user_groups
  has_many :ranks_user_groups, dependent: :destroy
  has_many :ranks, through: :ranks_user_groups

  scope :with_requirements, lambda { |product_id = nil|
    query = select('user_groups.id')
      .joins(:requirements).preload(:requirements).group('user_groups.id')
    if product_id
      query = query.where(user_group_requirements: { product_id: product_id })
    end
    query
  }

  scope :non_member, lambda { |user_id:, pay_period_id:|
    join_sql = UserUserGroup
      .where(user_id: user_id)
      .where('pay_period_id IS NULL OR pay_period_id = ?', pay_period_id)
      .to_sql
    joins("LEFT JOIN (#{join_sql}) uug ON user_groups.id = uug.user_group_id")
      .where('uug.user_group_id IS NULL')
  }

  def monthly?
    !requirements.entries.empty? && requirements.any?(&:monthly?)
  end

  def lifetime?
    !monthly?
  end

  def newly_qualified_user_ids(pay_period_id, previous_rank = nil)
    include_users = previous_rank && previous_rank.member_query(pay_period_id)
    exclude_users = user_user_groups.where(pay_period_id: pay_period_id)

    user_ids = requirements.map do |req|
      req.qualified_user_ids(
        pay_period_id: pay_period_id,
        include_users: include_users,
        exclude_users: exclude_users)
    end

    user_ids.inject(:&)
  end

  def join_qualified(pay_period_id, previous_rank = nil)
    user_ids = newly_qualified_user_ids(pay_period_id, previous_rank)
    attrs = user_ids.map do |user_id|
      { user_id: user_id, pay_period_id: pay_period_id }
    end

    user_user_groups.create!(attrs)
  end

  def requirements?
    !requirements.entries.empty?
  end

  def prouduct_requirement?(product_id)
    requirements? &&
      requirements.entries.any? { |req| req.product_id == product_id }
  end

  def add_user(user_id, pay_period_id)
    attrs = { user_id: user_id }
    attrs[:pay_period_id] = pay_period_id if monthly?
    user_user_groups.create!(attrs)
  end

  class << self
    def with_product_requirements(product_id)
      with_requirements.select do |group|
        group.prouduct_requirement?(product_id)
      end
    end

    def join_qualified(user:, pay_period: nil, product_id: nil)
      pay_period ||= MonthlyPayPeriod.current

      starting_rank = user.pay_as_rank(pay_period.id)
      ranks = Rank.where('id > ?', starting_rank)
        .preload(:user_groups, :requirements)

      ranks.each do |rank|
        groups = rank.qualified_groups(
          user:       user,
          pay_period: pay_period,
          product_id: product_id)
        break if groups.empty?
        groups.each { |group| group.add_user(user.id, pay_period.id) }
      end
    end
  end
end
