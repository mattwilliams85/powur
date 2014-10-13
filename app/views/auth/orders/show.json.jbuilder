siren json

json.partial! 'item', order: @order, detail: true

entities partial_entity(:user, @order.user, path: 'auth/users/item')
