klass :bonus_level

json.rel [ :item ]

json.properties do
  json.call(bonus_level, :level)
  json.amounts bonus_level.normalized_amounts.map(&:to_f)
  json.rank_path bonus_level.rank_path_id && bonus_level.rank_path.name
end

action_list = [ bonus_json.update_level_action(bonus_level) ]

if bonus_level.last?
  action_list << action(
    :delete, :delete,
    bonus_level_path(bonus_level))
end

actions(*action_list)
