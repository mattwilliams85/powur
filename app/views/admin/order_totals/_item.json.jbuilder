
klass :order_total

json.properties do
  json.(order_total, :pay_period_id, :personal, :group, :personal_lifetime, :group_lifetime)
  json.product order_total.product.name
  json.distributor order_total.user.full_name
end