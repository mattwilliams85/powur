class UserGroup < ActiveRecord::Base
  validates :title, presence: true
  validates :id, presence: true, uniqueness: true

  has_many :requirements, class_name: 'UserGroupRequirement', dependent: :destroy

  has_many :user_user_groups, dependent: :destroy
  has_many :users, through: :user_user_groups

  has_many :ranks_user_groups, dependent: :destroy
  has_many :ranks, through: :ranks_user_groups

  def monthly?
    !requirements.entries.empty? && requirements.any?(&:monthly?)
  end

  def lifetime?
    !monthly?
  end

  def qualified_user_ids
    requirements.map(&:qualified_user_ids).inject(:&) # intersection
  end

  def needs_qualification?
    !requirements.empty?
  end

  class << self
    def with_requirements
      UserGroup.includes(:requirements).select(&:needs_qualification?)
    end
  end
end
