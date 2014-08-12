siren json

json.partial! 'item', order: @order, detail: true

entities \
  'admin/products'  => { product: @order.product },
  'admin/users'     => { user: @order.user },
  'admin/customers' => { customer: @order.customer },
  partial: :item