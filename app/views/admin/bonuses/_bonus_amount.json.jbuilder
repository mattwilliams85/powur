klass :bonus_amount

json.rel [ :item ]

json.properties do
  json.call(bonus_amount, :level)
  json.amounts bonus_amount.normalize_amounts(all_ranks.size)
end

action_list = [ bonus_json.update_amount_action(bonus_amount) ]

if bonus_amount.last?
  action_list << action(
    :delete, :delete,
    bonus_amount_path(bonus_amount))
end

actions(*action_list)
