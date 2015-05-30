klass :order_total

entity_rel('item')

json.properties do
  json.call(order_total, :id, :pay_period_id, :product_id, :user_id, :personal, :group,
            :personal_lifetime, :group_lifetime)
  json.product order_total.product.name
  json.user order_total.user.full_name
end
