siren json

klass :orders, :list

json.entities @orders, partial: 'item', as: :order

actions index_action(@orders_path || orders_path, true)

links link(:self, @orders_path || orders_path)
