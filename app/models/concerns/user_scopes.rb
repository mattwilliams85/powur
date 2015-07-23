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

    scope :quote_performance, lambda { |user_id|
      with_quote_counts
        .where('quotes.status > ? or quotes.status IS NULL', 2)
        .with_parent(user_id)
        .order('quote_count desc')
    }

    scope :growth_performance, lambda { |user_id|
      with_weekly_downline_counts
        .with_parent(user_id)
        .order('dc.downline_count desc nulls last')
    }

    scope :team_size, lambda { |user_id|
      with_downline_counts
      .with_parent(user_id)
      .order("dc.downline_count desc nulls last")
    }

    scope :team_size, lambda { |user_id|
      with_downline_counts
      .with_parent(user_id)
      .order("dc.downline_count desc nulls last")
    }

    WEEKLY_DOWN_COUNTS_SELECT = \
      'unnest(users.upline) parent_id, count(users.id) - 1 downline_count'
    scope :weekly_downline_counts, lambda {
      select(WEEKLY_DOWN_COUNTS_SELECT).group('parent_id')
        .where('created_at > ?', 7.days.ago.to_s(:db))
    }

    scope :with_weekly_downline_counts, lambda {
      joins_sql = "left outer join (#{weekly_downline_counts.to_sql}) dc
        ON users.id = dc.parent_id"
      select('users.*, dc.downline_count').joins(joins_sql)
    }

    TEAM_COUNT_SELECT = \
      'unnest(users.upline) parent_id, count(users.id) - 1 team_count'
    scope :team_count, lambda { |ids: nil|
      sub_query = select(TEAM_COUNT_SELECT).group(:parent_id).to_sql
      query = select('tc.parent_id id, tc.team_count')
        .joins("inner join (#{sub_query}) tc on users.id = tc.parent_id")
      query = query.where(id: ids) if ids
      query
    }

    scope :quote_count, lambda { |ids: nil|
      sub_query = Quote.user_count(ids: ids).to_sql
      select('users.id, qc.quote_count')
        .joins("inner join (#{sub_query}) qc on users.id = qc.user_id")
    }

    scope :with_quote_counts, lambda {
      select('users.*, count(quotes.id) quote_count')
        .joins('left outer join quotes on users.id = quotes.user_id')
        .group('users.id')
    }

    scope :with_parent, lambda { |*user_ids|
      where('users.upline[array_length(users.upline, 1) - 1] IN (?)',
            user_ids.flatten)
    }

    scope :with_ancestor, lambda { |user_id|
      where('? = ANY (upline)', user_id).where('id <> ?', user_id)
        # .where('upline[array_length(upline, 1)] NOT IN (?)', user_id)
    }

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

    scope :pay_period_quote_counts, lambda { |pay_period|
      with_quote_counts
        .where('quotes.created_at > ?', pay_period.start_date)
        .where('quotes.created_at < ?', pay_period.end_date + 1.day)
    }

    scope :performance, lambda { |metric, period|
      case metric
      when 'quote_count'
        if period == 'lifetime'
          query = with_quote_counts
        else
          klass = period == 'monthly' ? MonthlyPayPeriod : WeeklyPayPeriod
          query = pay_period_quote_counts(klass.current)
        end
        query.order('quote_count desc')
      when 'personal_sales', 'group_sales'
        order_by = "order_totals.#{metric.split('_').first}"
        order_by += '_lifetime' if period == 'lifetime'
        with_order_totals(period).order("#{order_by} desc")
      else
        fail ArgumentError, "Unsupported metric value: #{metric}"
      end
    }

    scope :in_groups, lambda { |*ids|
      joins(:user_user_groups)
        .where(user_user_groups: { user_group_id: ids })
    }

    scope :ranked_up, -> { where.not(organic_rank: nil) }

    scope :needs_lifetime_rank_up, lambda {
      ranked_up.where('lifetime_rank is null or organic_rank > lifetime_rank')
    }

    scope :needs_organic_rank_up, lambda {
      joins_sql = UserUserGroup.highest_ranks.to_sql
      select('hr.highest_rank, users.id')
        .joins("join (#{joins_sql}) hr on hr.user_id = users.id")
        .where('organic_rank is null or organic_rank < hr.highest_rank')
    }

    scope :with_purchases, -> { joins(:product_receipts) }

    scope :advocates, lambda {
      where.not(id: partners.select('users.id'))
    }

    scope :partners, lambda {
      joins(product_receipts: :product).where(products: { slug: 'partner' })
    }

    scope :has_rank, lambda {
      where('lifetime_rank is not null or lifetime_rank != 0')
    }

    scope :eligible_parents, lambda { |user|
      where('NOT (? = ANY (upline))', user.id)
        .where('id <> ?', user.parent_id)
    }
  end

  module ClassMethods
  end
end
