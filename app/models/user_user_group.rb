class UserUserGroup < ActiveRecord::Base
  self.primary_keys = :user_id, :user_group_id

  belongs_to :user
  belongs_to :user_group

  validates_presence_of :user_id, :user_group_id

  scope :highest_ranks, ->(user_id = nil) {
    query = select('max(rank_id) highest_rank, user_id')
      .joins(user_group: :ranks_user_groups)
      .group('user_user_groups.user_id')
    query = query.where('user_user_groups.user_id' => user_id) if user_id
    query
  }

  class << self
    def populate(opts = {})
      UserGroup.with_requirements.each do |group|
        user_ids = group.qualified_user_ids
        user_ids -= where(user_id: user_ids).pluck(:user_id)
        attrs = user_ids.map do |user_id|
          { user_id: user_id, user_group_id: group.id }
        end
        create!(attrs)
      end
    end

    def populate_for_user_product(user_id, product_id)
      groups = UserGroup
        .non_member(user_id)
        .with_requirements(product_id)
      groups.each do |group|
        next unless group.user_qualifies?(user_id)
        create!(user_id: user_id, user_group_id: group.id)
      end
    end
  end
end
