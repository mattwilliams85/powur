siren json

klass :orders, :list

json.entities @orders, partial: 'item', as: :order

actions index_action(@orders_path || admin_orders_path, true)

self_link @orders_path || admin_orders_path
