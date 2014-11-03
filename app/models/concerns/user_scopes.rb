module UserScopes
  extend ActiveSupport::Concern

  included do
    scope :with_upline_at, lambda { |id, level|
      where('upline[?] = ?', level, id).where('id != ?', id)
    }
    scope :at_level, ->(rank) { where('array_length(upline, 1) = ?', rank) }

    CHILD_COUNT_LIST = "
      SELECT u.*, child_count - 1 downline_count
      FROM (
        SELECT unnest(upline) parent_id, count(id) child_count
        FROM users
        GROUP BY parent_id) c INNER JOIN users u ON c.parent_id = u.id
      WHERE u.upline[?] = ? AND array_length(u.upline, 1) = ?
      ORDER BY u.last_name, u.first_name, u.id;"

    scope :child_count_list, lambda { |user|
      find_by_sql([ CHILD_COUNT_LIST, user.level, user.id, user.level + 1 ])
    }
    scope :with_parent, lambda { |*user_ids|
      where('upline[array_length(upline, 1) - 1] IN (?)', user_ids.flatten)
    }
    scope :with_ancestor, lambda { |user_id|
      where('? = ANY (upline)', user_id)
        .where('upline[array_length(upline, 1)] NOT IN (?)', user_id)
    }

    PERF_SELECT = 'users.*, ' +
        %w(personal group personal_lifetime group_lifetime)
        .map { |f| "order_totals.#{f}" }.join(', ')
    PERF_JOIN = 'left join order_totals on users.id = order_totals.user_id'

    scope :order_totals, lambda { |metric, period|
      order_by = "order_totals.#{metric}"
      order_by += '_lifetime' if period == 'lifetime'
      pp_klass = period == 'monthly' ? MonthlyPayPeriod : WeeklyPayPeriod
      where_sql = { pay_period_id: [ pp_klass.current.id, nil ],
                    product_id:    [ Product.default_id, nil ] }
      where_sql = { order_totals: where_sql }

      select(PERF_SELECT).joins(PERF_JOIN)
        .where(where_sql).order("#{order_by} desc")
    }

    scope :quote_count, lambda { |period|
      query = select('users.*, count(quotes.id) quote_count')
        .joins('left outer join quotes on users.id = quotes.user_id')
        .group('users.id').order('quote_count desc')
      if period != 'lifetime'
        klass = period == 'monthly' ? MonthlyPayPeriod : WeeklyPayPeriod
        pay_period = klass.current
        query = query
          .where('quotes.created_at > ?', pay_period.start_date)
          .where('quotes.created_at < ?', pay_period.end_date + 1.day)
      end
      query
    }

    scope :performance, lambda { |metric, period|
      metric == 'quotes' ? quote_count(period) : order_totals(metric, period)
    }

  end

  module ClassMethods
  end
end
