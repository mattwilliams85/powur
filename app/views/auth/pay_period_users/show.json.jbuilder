siren json

klass :user

json.partial! 'item', lead_totals: lead_totals

entity_list = []

# entity_list.push(
#   entity(%w(list bonuse),
#          'pay_period-users',
#          pay_period_users_path(@pay_period)))

entities(*entity_list)
