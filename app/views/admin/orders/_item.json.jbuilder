klass :order

entity_rel(local_assigns[:rel]) unless local_assigns[:detail]

json.properties do
  json.call(order, :quantity, :order_date, :status)
  json.product order.product.name
  json.distributor order.user.full_name
  json.customer order.customer.full_name
end

links link(:self, admin_order_path(order))
