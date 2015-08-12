class RanksUserGroup < ActiveRecord::Base
  self.primary_keys = :rank_id, :user_group_id

  belongs_to :rank
  belongs_to :user_group

  validates_presence_of :rank_id, :user_group_id
end
