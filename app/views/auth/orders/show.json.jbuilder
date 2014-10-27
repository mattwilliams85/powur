siren json

json.partial! 'item', order: @order, detail: true

entities entity('auth/users/item', 'order-user', user: @order.user)
