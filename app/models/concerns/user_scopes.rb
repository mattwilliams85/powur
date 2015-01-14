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

    scope :with_parent, lambda { |*user_ids|
      where('users.upline[array_length(users.upline, 1) - 1] IN (?)',
            user_ids.flatten)
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

    scope :with_quote_counts, lambda {
      select('users.*, count(quotes.id) quote_count')
        .joins('left outer join quotes on users.id = quotes.user_id')
        .group('users.id')
    }

    scope :pay_period_quote_counts, lambda { |pay_period|
      with_quote_counts
        .where('quotes.created_at > ?', pay_period.start_date)
        .where('quotes.created_at < ?', pay_period.end_date + 1.day)
    }

    scope :performance, lambda { |metric, period|
      case metric
      when 'quotes'
        if period == 'lifetime'
          query = with_quote_counts
        else
          klass = period == 'monthly' ? MonthlyPayPeriod : WeeklyPayPeriod
          query = pay_period_quote_counts(klass.current)
        end
        query.order('quote_count desc')
      when 'personal', 'group'
        order_by = "order_totals.#{metric}"
        order_by += '_lifetime' if period == 'lifetime'
        with_order_totals(period).order("#{order_by} desc")
      else
        fail ArgumentError, "Unsupported metric value: #{metric}"
      end
    }

  end

  module ClassMethods
  end
end
