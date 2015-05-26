class UserGroup < ActiveRecord::Base
  validates :title, presence: true
  validates :id, presence: true, uniqueness: true

  has_many :requirements, class_name: 'UserGroupRequirement', dependent: :destroy

  has_many :user_user_groups, dependent: :destroy
  has_many :users, through: :user_user_groups

  has_many :ranks_user_groups, dependent: :destroy
  has_many :ranks, through: :ranks_user_groups
end
