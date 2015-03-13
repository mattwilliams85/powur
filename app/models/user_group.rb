class UserGroup < ActiveRecord::Base
  has_many :user_user_groups, dependent: :destroy
  has_many :users, through: :user_user_groups
  has_many :requirements, class_name: 'UserGroupRequirement', dependent: :destroy
end
