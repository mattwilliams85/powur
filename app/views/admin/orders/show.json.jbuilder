siren json

json.partial! 'item', order: @order, detail: true

entity_list = [
  entity('admin/products/item', 'order-product', product: @order.product),
  entity('admin/users/item', 'order-user', user: @order.user),
  entity('admin/customers/item', 'order-customer', customer: @order.customer) ]

if @order.bonus_payments?
  entity_list << entity(%w(list bonus_payments),
                        'order-bonus_payments',
                        admin_order_bonus_payments_path(@order))
end
entities(*entity_list)
