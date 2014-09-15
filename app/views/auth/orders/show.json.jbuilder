siren json

json.partial! 'item', order: @order, detail: true

entities \
  'auth/users'     => { user: @order.user },
  partial: :item