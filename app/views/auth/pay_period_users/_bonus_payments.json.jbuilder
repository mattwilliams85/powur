klass :bonus_payments, :list

entity_rel local_assigns[:rel]

json.entities bonus_payments,
              partial: 'auth/bonus_payments/item',
              as:      :bonus_payment
