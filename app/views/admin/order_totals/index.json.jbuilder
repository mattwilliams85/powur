siren json

klass :order_totals, :list

json.entities @order_totals, partial: 'item', as: :order_total

actions index_action(@orders_totals_path)

links link(:self, @orders_totals_path)
