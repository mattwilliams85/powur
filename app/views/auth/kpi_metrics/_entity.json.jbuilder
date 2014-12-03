klass :user

json.rel [ :item ] unless local_assigns[:detail]

json.properties do
  json.avatar user.avatar
  json.first_name user.first_name
  json.last_name user.last_name
  json.id user.id
end

# json.test @user_orders
json.entities orders_for_user(@user_orders, user.id), partial: 'orders', as: :order
