module UserScopes
  extend ActiveSupport::Concern

  included do
    scope :with_upline_at, lambda { |id, level|
      where('upline[?] = ?', level, id).where('id != ?', id)
    }
    scope :at_level, ->(rank) { where('array_length(upline, 1) = ?', rank) }

    # CHILD_COUNT_LIST = "
    #   SELECT u.*, child_count - 1 downline_count
    #   FROM (
    #     SELECT unnest(upline) parent_id, count(id) child_count
    #     FROM users
    #     GROUP BY parent_id) c INNER JOIN users u ON c.parent_id = u.id
    #   WHERE u.upline[?] = ? AND array_length(u.upline, 1) = ?
    #   ORDER BY u.last_name, u.first_name, u.id;"
    # find_by_sql([ CHILD_COUNT_LIST, user.level, user.id, user.level + 1 ])

    scope :for_bonuses, lambda {
      select(:id, :upline, :lifetime_rank, :organic_rank, :rank_path_id)
    }

    scope :within_date_range, ->(begin_date, end_date) {
      where('created_at between ? and ?', begin_date, end_date)
    }

    scope :quote_performance, lambda { |user_id|
      with_quote_counts
      .where("quotes.status > ? or quotes.status IS NULL", 2)
      .with_parent(user_id)
      .order("quote_count desc")
    }

    scope :growth_performance, lambda { |user_id|
      with_weekly_downline_counts
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

    DOWN_COUNTS_SELECT = \
      'unnest(users.upline) parent_id, count(users.id) - 1 downline_count'
    scope :downline_counts, lambda {
      select(DOWN_COUNTS_SELECT).group('parent_id')
    }

    scope :with_downline_counts, lambda {
      joins_sql = "INNER JOIN (#{downline_counts.to_sql}) dc
        ON users.id = dc.parent_id"
      select('users.*, dc.downline_count').joins(joins_sql)
    }


    scope :with_quote_counts, lambda {
      select('users.*, count(quotes.id) quote_count')
        .joins('left outer join quotes on users.id = quotes.user_id')
        .group('users.id')
    }

    scope :with_parent, lambda { |*user_ids|
      where('users.upline[array_length(users.upline, 1) - 1] IN (?)', user_ids.flatten)
    }

    scope :with_ancestor, lambda { |user_id|
      where('? = ANY (upline)', user_id)
        .where('upline[array_length(upline, 1)] NOT IN (?)', user_id)
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

    scope :ranked_up, ->{ where.not(organic_rank: nil) }
    scope :needs_lifetime_rank_up, ->{
      ranked_up.where('lifetime_rank is null or organic_rank > lifetime_rank')
    }

    scope :needs_organic_rank_up, ->{
      joins_sql = UserUserGroup.highest_ranks.to_sql
      select('hr.highest_rank, users.id')
        .joins("join (#{joins_sql}) hr on hr.user_id = users.id")
        .where('organic_rank is null or organic_rank < hr.highest_rank')
    }

    scope :has_rank, -> { where('lifetime_rank is not null or lifetime_rank != 0') }
  end

  module ClassMethods
  end
end
