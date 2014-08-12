siren json

json.partial! 'item', quote: @quote, detail: true

json.properties do
  
end

entity_list = { 
  partial: :item,
  'admin/products'  => { product: @quote.product, rel: 'quote-product' },
  'admin/users'     => { user: @quote.user, rel: 'quote-user' },
  'admin/customers' => { customer: @quote.customer, rel: 'quote-customer' } }

if @quote.order?
  entity_list['admin/orders'] = { order: @quote.order }
else
  actions \
    action(:create_order, :post, orders_path).
      field(:quote_id, :number, value: @quote.id).
      field(:order_date, :datetime, value: DateTime.current, required: false)
end

entities entity_list
