klass :bonus_level

json.rel [ :item ]

json.properties do
  json.(bonus_level, :level, :amounts)
end

action_list = []

if bonus.can_add_amounts?
  action_list << action(:update, :patch, bonus_level_path(bonus, bonus_level.level)).
    field(:amounts, :dollar_percentage, array: true, first: bonus_level.rank_range.first,
      last: bonus_level.rank_range.last, value: bonus_level.amounts,
      total: bonus.available_bonus_amount, max: bonus.available_bonus_percentage)
end

if bonus_level.is_last?
  action_list << action(:delete, :delete, bonus_level_path(bonus, bonus_level.level))
end

actions *action_list

