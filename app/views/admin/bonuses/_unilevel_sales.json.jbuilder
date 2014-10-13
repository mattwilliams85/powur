
json.properties do
  json.compress bonus.compress
end

json.entities \
  [ { bonus: bonus, data: bonus.requirements, partial: 'requirements' },
    { bonus: bonus, data: bonus.bonus_levels, partial: 'bonus_levels' } ],
  partial: 'entities', as: :entity

actions \
  action(:update, :patch, bonus_path(bonus))
    .field(:name, :text, value: bonus.name)
    .field(:schedule, :select,
           options: Bonus.enum_options(:schedules),
           value:   bonus.schedule)
    .field(:use_rank_at, :select,
           options: Bonus.enum_options(:use_rank_ats),
           value:   bonus.use_rank_at)
    .field(:compress, :checkbox, value: bonus.compress),
  action(:delete, :delete, bonus_path(bonus))
