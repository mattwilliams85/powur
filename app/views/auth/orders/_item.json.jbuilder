orders_json.item_init(local_assigns[:rel] || 'item')

orders_json.list_item_properties(order)

self_link user_order_path(order.user_id, order)
