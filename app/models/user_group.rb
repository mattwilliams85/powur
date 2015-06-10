class UserGroup < ActiveRecord::Base
  validates :title, presence: true
  validates :id, presence: true, uniqueness: true

  has_many :requirements, class_name: 'UserGroupRequirement', dependent: :destroy

  has_many :user_user_groups, dependent: :destroy
  has_many :users, through: :user_user_groups

  has_many :ranks_user_groups, dependent: :destroy
  has_many :ranks, through: :ranks_user_groups

  scope :with_requirements, ->(product_id = nil) {
    query = select('user_groups.id')
      .joins(:requirements)
      .group('user_groups.id')
    if product_id
      query = query.where(user_group_requirements: { product_id: product_id })
    end
    query
  }

  scope :non_member, ->(user_id) {
    join_sql = UserUserGroup.where(user_id: user_id).to_sql
    joins("left outer join (#{join_sql}) uug on user_groups.id = uug.user_group_id")
      .where("uug.user_group_id is null")
  }

  def monthly?
    !requirements.entries.empty? && requirements.any?(&:monthly?)
  end

  def lifetime?
    !monthly?
  end

  def qualified_user_ids
    requirements.map(&:qualified_user_ids).inject(:&) # intersection
  end

  def user_qualifies?(user_id)
    needs_qualification? &&
      requirements.entries.all? { |req| req.user_qualified?(user_id) }
  end

  def needs_qualification?
    !requirements.entries.empty?
  end

  def has_prouduct_requirement?(product_id)
    needs_qualification? &&
      requirements.entries.any? { |req| req.product_id == product_id }
  end
end
