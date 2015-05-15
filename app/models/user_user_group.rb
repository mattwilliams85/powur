class UserUserGroup < ActiveRecord::Base
  self.primary_keys = :user_id, :user_group_id

  belongs_to :user
  belongs_to :user_group

  validates_presence_of :user_id, :user_group_id
end
