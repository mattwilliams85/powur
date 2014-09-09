
json.properties do
  json.amounts bonus.normalized_amounts.map(&:to_f)
end

json.entities \
  [ { bonus: bonus, data: bonus.requirements, partial: 'requirements' } ], 
  partial: 'entities', as: :entity

update = action(:update, :patch, bonus_path(bonus)).
  field(:name, :text, value: bonus.name).
  field(:schedule,    :select, options: Bonus.enum_options(:schedules), value: bonus.schedule).
  field(:use_rank_at, :select, options: Bonus.enum_options(:use_rank_ats), value: bonus.use_rank_at)

update.amount_field(bonus) if bonus.can_add_amounts?

actions update, action(:delete, :delete, bonus_path(bonus))
