siren json

json.partial! 'item', order: @order, detail: true

entities \
  'admin/products' => { product: @order.product },
  partial: :item