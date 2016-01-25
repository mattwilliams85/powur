module UserTotalsScopes
  extend ActiveSupport::Concern

  included do
    scope :order_leads, lambda { |status|
      sql = [ "cast(lifetime_leads -> '%s' as int) desc nulls last",
              status ]
      order(sanitize_sql(sql))
    }

    scope :quantity_met, lambda { |status:, quantity:, month: nil|
      if month
        where('(monthly_leads -> ? ->> ?)::int >=  ?', month, status, quantity)
      else
        where('(lifetime_leads ->> ?)::int >= ?', status, quantity)
      end
    }

    scope :exclude_users, lambda { |query|
      joins("LEFT JOIN (#{query.to_sql}) eu ON user_totals.id = eu.user_id")
        .where('eu.user_id IS NULL')
    }
    scope :include_users, lambda { |query|
      joins("INNER JOIN (#{query.to_sql}) iu ON user_totals.id = iu.user_id")
    }

    scope :lead_leg_counts, lambda { |status|
      sql = [ 'id, jsonb_array_elements_text(team_leads -> ?)::int totals',
              status ]
      select(sanitize_sql(sql))
        .where('team_leads ? :status', status: status)
    }

    scope :monthly_lead_leg_counts, lambda { |status, month|
      field = 'monthly_team_leads -> ? -> ?'
      sql = [ "id, jsonb_array_elements_text(#{field})::int totals",
              month, status ]
      select(sanitize_sql(sql))
        .where('(monthly_team_leads -> ? -> ?) IS NOT NULL', month, status)
    }

    scope :lead_leg_count_met,
          lambda { |status:, quantity:, leg_count:, month: nil|
            join_sql =
                if month
                  monthly_lead_leg_counts(status, month)
                else
                  lead_leg_counts(status)
                end
            joins("INNER JOIN (#{join_sql.to_sql}) t ON t.id = user_totals.id")
              .where('t.totals >= ?', quantity)
              .group(:id)
              .having('count(t.totals) >= ?', leg_count)
          }

    scope :monthly_team_count_met, lambda { |month:, status:, quantity:|
      join_sql = monthly_lead_leg_counts(status, month).to_sql
      having_sql = "
        (coalesce(monthly_leads -> ? ->> ?, '0')::int +
        coalesce(sum(t.totals), '0')::int) >= ?"
      joins("LEFT JOIN (#{join_sql}) t ON t.id = user_totals.id")
        .group(:id)
        .having(having_sql, month, status, quantity)
    }

    scope :lifetime_team_count_met, lambda { |status:, quantity:|
      join_sql = lead_leg_counts(status).to_sql
      having_sql = "
        (coalesce(lifetime_leads ->> :status, '0')::int +
        coalesce(sum(t.totals), '0')::int) >= :quantity"
      joins("LEFT JOIN (#{join_sql}) t ON t.id = user_totals.id")
        .group(:id).having(having_sql, status: status, quantity: quantity)
    }
  end
end
