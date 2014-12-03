klass :order

json.rel [ :item ] unless local_assigns[:detail]

json.properties do
  json.day order.order_date.strftime("%u")
end


