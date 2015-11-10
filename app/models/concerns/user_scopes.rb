module UserScopes
  extend ActiveSupport::Concern

  included do
    scope :with_upline_at, lambda { |id, level|
      where('upline[?] = ?', level, id).where('id != ?', id)
    }

    scope :at_level, ->(rank) { where('array_length(upline, 1) = ?', rank) }

    scope :for_bonuses, lambda {
      select(:id, :upline, :lifetime_rank, :organic_rank, :rank_path_id)
    }

    scope :within_date_range, lambda { |begin_date, end_date|
      where('created_at between ? and ?', begin_date, end_date)
    }

    scope :growth_performance, lambda { |user_id|
      with_weekly_downline_counts
        .with_ancestor(user_id)
        .order('dc.downline_count desc nulls last')
    }

    scope :not_admin, lambda {
      where.not("'admin' = ANY(roles)")
    }

    scope :monthly_leaders, lambda {
      select('users.*, COUNT(ml.submitted_at) AS leader_count')
        .joins("INNER JOIN (#{Lead.all.submitted.to_sql}) ml ON users.id = ml.user_id")
        .where('ml.submitted_at >= ?', Time.zone.today.beginning_of_month)
        .group('users.id')
        .order('leader_count desc')
    }

    WEEKLY_DOWN_COUNTS_SELECT = \
      'unnest(users.upline) parent_id, count(users.id) - 1 downline_count'
    scope :weekly_downline_counts, lambda {
      select(WEEKLY_DOWN_COUNTS_SELECT).group('parent_id')
        .where('created_at >= ?', 7.days.ago)
    }

    scope :with_weekly_downline_counts, lambda {
      joins_sql = "left outer join (#{weekly_downline_counts.to_sql}) dc
        ON users.id = dc.parent_id"
      select('users.*, dc.downline_count').joins(joins_sql)
    }

    TEAM_COUNT_SELECT = \
      'unnest(users.upline) parent_id, count(users.id) - 1 team_count'
    scope :team_count, lambda {
      sub_query = select(TEAM_COUNT_SELECT).group(:parent_id)
      select('*')
        .joins("LEFT JOIN (#{sub_query.to_sql}) tc ON users.id = tc.parent_id")
    }

    scope :lead_count, lambda { |lead_query = Lead.submitted|
      sub_query = lead_query.user_count
      select('coalesce(lc.lead_count, 0) lead_count, users.*')
        .joins("LEFT JOIN (#{sub_query.to_sql}) lc ON users.id = lc.user_id")
    }

    scope :team_lead_count, lambda { |lead_query|
      sub_sql = lead_query.user_count.to_sql
      select('unnest(upline) id,
              CAST(coalesce(sum(lc.lead_count), 0) AS integer) lead_count')
        .joins("LEFT JOIN (#{sub_sql}) lc ON lc.user_id = users.id")
        .group('1')
    }

    scope :with_parent, lambda { |*user_ids|
      where('users.upline[array_length(users.upline, 1) - 1] IN (?)',
            user_ids.flatten)
    }

    scope :all_team, ->(id) { where('? = ANY (upline)', id) }
    scope :with_ancestor, ->(id) { all_team(id).where('users.id <> ?', id) }

    OT_SELECT_FIELDS = %w(personal group personal_lifetime group_lifetime)
    ORDER_TOTALS_SELECT = \
      'users.*, ' + OT_SELECT_FIELDS.map do |f|
        "coalesce(order_totals.#{f}, 0) as #{f}"
      end.join(', ')
    ORDER_TOTALS_JOIN = \
      'left join order_totals on users.id = order_totals.user_id'

    scope :with_order_totals, lambda { |period|
      klass = period == 'monthly' ? MonthlyPayPeriod : WeeklyPayPeriod
      where_sql = { pay_period_id: [ klass.current.id, nil ],
                    product_id:    [ Product.default_id, nil ] }
      where_sql = { order_totals: where_sql }

      select(ORDER_TOTALS_SELECT).joins(ORDER_TOTALS_JOIN).where(where_sql)
    }

    scope :in_groups, lambda { |*ids|
      joins(:user_user_groups)
        .where(user_user_groups: { user_group_id: ids })
    }

    scope :ranked_up, -> { where.not(organic_rank: nil) }

    scope :needs_lifetime_rank_up, lambda {
      join = UserUserGroup.highest_ranks
      joins("INNER JOIN (#{join.to_sql}) hr ON users.id = hr.user_id")
        .where('hr.highest_rank <> users.lifetime_rank')
    }

    scope :needs_organic_rank_up, lambda { |pay_period_id: nil|
      partners.where('organic_rank <> 1')
    }

    scope :with_purchases, -> { joins(:product_receipts) }
    scope :purchased, lambda { |product_id|
      joins(:product_receipts)
        .where(product_receipts: { product_id: product_id })
    }

    scope :advocates, lambda {
      where.not(id: partners.select('users.id'))
    }

    scope :partners, lambda {
      join = ProductReceipt.partner.select('distinct(user_id) user_id')
      joins("INNER JOIN (#{join.to_sql}) pr ON pr.user_id = users.id")
    }

    scope :has_rank, lambda {
      where('lifetime_rank is not null or lifetime_rank != 0')
    }

    scope :installations, lambda { |id|
      all_team(id)
        .joins(:leads)
        .where.not(leads: { installed_at: nil })
    }

    scope :eligible_parents, lambda { |user|
      where('NOT (? = ANY (upline))', user.id)
        .where('id <> ?', user.parent_id)
    }

    scope :has_phone, lambda {
      where("exist(contact, 'valid_phone') = true")
        .where("contact->'valid_phone' != ''")
    }
    scope :allows_sms, lambda {
      where([
        '(profile IS NULL ' \
        "OR exist(profile, 'allow_sms') = ? " \
        "OR profile -> 'allow_sms' != ?)",
        false, 'false'])
    }
    scope :can_sms, -> { has_phone.allows_sms }

    scope :unnested_children, lambda { |*parent_ids|
      query = select('users.id, unnest(upline) parent_id')
      unless parent_ids.empty?
        query = query.where("ARRAY[#{parent_ids.flatten.join(',')}] && upline")
      end
      query
    }

    scope :child_lead_counts, lambda { |parent_ids: nil|
      select('users.id, unnest(upline) parent_id,
             coalesce(lc.lead_count, 0) lead_count')
        .joins("LEFT JOIN (#{Lead.user_count.to_sql})
                  lc ON lc.user_id = users.id")
    }
  end
end
