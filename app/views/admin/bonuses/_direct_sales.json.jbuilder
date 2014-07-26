
json.properties do
  json.amounts bonus.bonus_amounts
end

json.entities \
  [ { bonus: bonus, data: bonus.requirements, partial: 'requirements' } ], 
  partial: 'entities', as: :entity

update = action(:update, :patch, bonus_path(bonus)).
  field(:name, :text, value: bonus.name).
  field(:schedule, :select, options: Bonus::SCHEDULES, value: bonus.schedule)

if (rank_range = Rank.rank_range)
  update.field(:amounts, :number, array: true, 
    first: rank_range.first, last: rank_range.last)
end

actions update, action(:delete, :delete, bonus_path(bonus))
