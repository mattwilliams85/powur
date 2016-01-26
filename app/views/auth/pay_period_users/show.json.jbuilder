siren json

klass :user

json.partial! 'item', user: @user

entity_list = [
  entity('bonus_payments',
         'user-bonus_payments',
         bonus_payments: @bonus_payments)]

entities(*entity_list)

self_link request.path
