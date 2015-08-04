class UserUserGroup < ActiveRecord::Base
  self.primary_keys = :user_id, :user_group_id

  belongs_to :user
  belongs_to :user_group

  validates_presence_of :user_id, :user_group_id

  scope :highest_ranks, lambda { |user_id: nil, pay_period_id: nil|
    query = select('max(rank_id) highest_rank, user_id')
      .joins(user_group: :ranks_user_groups)
      .group('user_user_groups.user_id')
    query = query.where('user_user_groups.user_id' => user_id) if user_id
    if pay_period_id
      condition = 'pay_period_id is null OR pay_period_id = ?'
      query = query.where(condition, pay_period_id)
    end
    query
  }

  class << self
    def populate(pay_period_id)
      UserGroup.with_requirements.each do |group|
        user_ids = group.qualified_user_ids(pay_period_id)

        existing = where(user_id:       user_ids,
                         user_group_id: group.id)
        if group.monthly?
          existing = existing.where(pay_period_id: pay_period_id)
        end
        user_ids -= existing.pluck(:user_id)

        attrs = user_ids.map do |user_id|
          group_attrs = { user_id: user_id, user_group_id: group.id }
          group_attrs[:pay_period_id] = pay_period_id if group.monthly?
          group_attrs
        end
        create!(attrs)
      end
    end

    def populate_all!(pp_ids = nil)
      pp_ids ||= MonthlyPayPeriod.relevant_ids
      pp_ids.each { |pp_id| populate(pp_id) }
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
