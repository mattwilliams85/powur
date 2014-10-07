
klass :order_total

json.rel [ :item ] unless local_assigns[:detail]

json.properties do
  json.call(order_total, :id, :pay_period_id, :personal, :group,
            :personal_lifetime, :group_lifetime)
  json.product order_total.product.name
  json.distributor order_total.user.full_name
end
