siren json

json.partial! 'item', order: @order, detail: true

entity_list = [
  partial_entity(:product, @order.product, path: 'admin/products/item'),
  partial_entity(:user, @order.user, path: 'admin/users/item'),
  partial_entity(:customer, @order.customer, path: 'admin/customers/item') ]

if @order.bonus_payments?
  entity_list << ref_entity(%w(list bonus_payments),
                            'order-bonus_payments',
                            admin_order_bonus_payments_path(@order))
end
entities(*entity_list)
