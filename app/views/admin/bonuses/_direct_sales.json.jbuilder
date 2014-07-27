
json.properties do
  json.amounts bonus.amounts
end

json.entities \
  [ { bonus: bonus, data: bonus.requirements, partial: 'requirements' } ], 
  partial: 'entities', as: :entity

update = action(:update, :patch, bonus_path(bonus)).
  field(:name, :text, value: bonus.name).
  field(:schedule, :select, options: Bonus::SCHEDULES, value: bonus.schedule)

if bonus.can_add_amounts?
  update.field(:amounts, :dollar_percentage, array: true,
    first: bonus.rank_range.first, last: bonus.rank_range.last,
    total: bonus.available_bonus_amount, max: bonus.available_bonus_percentage)
end

actions update, action(:delete, :delete, bonus_path(bonus))
