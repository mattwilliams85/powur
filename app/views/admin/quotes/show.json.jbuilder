siren json

json.partial! 'item', quote: @quote, detail: true

entity_list = [
  partial_entity(:product, @quote.product, path: 'admin/products/item'),
  partial_entity(:user, @quote.user, path: 'admin/users/item'),
  partial_entity(:customer, @quote.customer, path: 'admin/customers/item') ]

if @quote.order?
  entity_list << partial_entity(:order, @quote.order, path: 'admin/orders/item')
else
  actions \
    action(:create_order, :post, orders_path)
      .field(:quote_id, :number, value: @quote.id)
      .field(:order_date, :datetime, value: DateTime.current, required: false)
end

entities(*entity_list)
