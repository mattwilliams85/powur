klass :lead_totals, :list

entity_rel local_assigns[:rel]

json.entities lead_totals,
              partial: 'auth/lead_totals/item',
              as:      :lead_totals
