klass :bonus_totals, :list

entity_rel local_assigns[:rel]

json.entities bonus_totals,
              partial: 'bonus_total',
              as:      :bonus_total
