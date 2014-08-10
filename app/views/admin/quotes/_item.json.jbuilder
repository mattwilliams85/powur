klass :quote

json.rel [ :item ] unless local_assigns[:detail]

json.properties do
  json.(quote, :id, :data_status, :created_at)
  json.user quote.user.full_name
  json.customer quote.customer.full_name
  json.product quote.product.name
end

if quote.order?
  json.entities do
    json.array! [ quote.order ] do |order|
      json.partial! 'admin/orders/item', order: order
    end
  end
else
  actions \
    action(:create_order, :post, orders_path).
      field(:quote_id, :number, value: quote.id).
      field(:order_date, :datetime, value: DateTime.current, required: false)
end


