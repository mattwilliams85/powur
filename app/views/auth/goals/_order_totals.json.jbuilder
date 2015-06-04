klass :order_totals, :list

entity_rel(rel)

json.entities @order_totals, partial: 'auth/order_totals/item', as: :order_total
