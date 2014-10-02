siren json

klass :order_totals, :list

json.entities @order_totals, partial: 'item', as: :order_total

actions index_action(@order_totals_path)

links link(:self, @order_totals_path)
