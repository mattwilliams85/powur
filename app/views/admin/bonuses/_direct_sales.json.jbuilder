
json.properties do
  json.amounts bonus.normalized_amounts
end

json.entities \
  [ { bonus: bonus, data: bonus.requirements, partial: 'requirements' } ], 
  partial: 'entities', as: :entity

update = action(:update, :patch, bonus_path(bonus)).
  field(:name, :text, value: bonus.name).
  field(:schedule, :select, options: Bonus::SCHEDULES, value: bonus.schedule)

update.amount_field(bonus) if bonus.can_add_amounts?

actions update, action(:delete, :delete, bonus_path(bonus))
