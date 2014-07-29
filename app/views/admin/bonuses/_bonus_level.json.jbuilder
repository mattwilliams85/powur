klass :bonus_level

json.rel [ :item ]

json.properties do
  json.(bonus_level, :level)
  json.amounts bonus_level.normalized_amounts
end

action_list = []

if bonus_level.bonus.can_add_amounts?
  path = bonus_level_path(bonus_level.bonus, bonus_level.level)
  action_list << action(:update, :patch, path).amount_field(bonus_level)
end

if bonus_level.is_last?
  action_list << action(:delete, :delete, bonus_level_path(bonus_level.bonus, bonus_level.level))
end

actions *action_list

