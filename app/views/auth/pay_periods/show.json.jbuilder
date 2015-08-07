siren json

klass :pay_period

json.partial! 'item', pay_period: @pay_period, detail: true

entity_list = []

entity_list.push(
  entity(%w(list users),
         'pay_period-users',
         pay_period_users_path(@pay_period)))

entities(*entity_list)
