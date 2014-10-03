siren json

json.partial! 'item', order: @order, detail: true

entities \
  partial_entity(:product, @order.product, path: 'admin/products/item'),
  partial_entity(:user, @order.user, path: 'admin/users/item'),
  partial_entity(:customer, @order.customer, path: 'admin/customers/item')
