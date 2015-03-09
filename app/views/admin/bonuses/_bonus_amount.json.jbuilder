klass :bonus_level

json.rel [ :item ]

json.properties do
  json.call(bonus_amount, :level)
  json.amounts bonus_amount.normalize_amounts(all_ranks.size)
  json.rank_path do
    json.id bonus_amount.rank_path_id
    if bonus_amount.rank_path_id
      json.name bonus_level.rank_path.name
    end
  end
end

action_list = [ bonus_json.update_level_action(bonus_level) ]

if bonus_amount.last?
  action_list << action(
    :delete, :delete,
    bonus_amount_path(bonus_amount))
end

actions(*action_list)
