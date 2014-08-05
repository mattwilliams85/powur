klass :quote

json.rel [ :item ] unless local_assigns[:detail]

json.properties do
  json.(quote, :data_status)
  json.user quote.user.full_name
  json.customer quote.customer.full_name
  json.product quote.product.name
end

actions \
  action(:create_order, :post, orders_path).
    field(:quote_id, :number, value: quote.id)