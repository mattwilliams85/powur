klass :bonus_level

json.rel [ :item ]

json.properties do
  json.(bonus_level, :level, :amounts)
end

actions \
  action(:update, :patch, bonus_level_path(bonus, bonus_level.level)).
    field(:amounts, :number, array: true, first: bonus_level.rank_range.first,
      last: bonus_level.rank_range.last, value: bonus_level.amounts),
  action(:delete, :delete, bonus_level_path(bonus, bonus_level.level))

