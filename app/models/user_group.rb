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

  def qualified_user_ids(pay_period_id)
    user_ids = requirements.map do |req|
      req.qualified_user_ids(pay_period_id)
    end
    user_ids.inject(:&) # intersection
  end

  def requirements?
    !requirements.entries.empty?
  end

  def user_qualifies?(user_id, pay_period = nil)
    requirements? && requirements.entries
      .all? { |req| req.user_qualified?(user_id, pay_period) }
  end

  def prouduct_requirement?(product_id)
    requirements? &&
      requirements.entries.any? { |req| req.product_id == product_id }
  end

  class << self
    def with_product_requirements(product_id)
      with_requirements.select do |group|
        group.prouduct_requirement?(product_id)
      end
    end
  end
end
