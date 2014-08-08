klass :order

json.rel [ :item ] unless local_assigns[:detail]

json.properties do
  json.(order, :quantity, :order_date, :status)
  json.product order.product.name
  json.distributor order.user.full_name
  json.customer order.customer.full_name
end

links \
  link :self, order_path(order)