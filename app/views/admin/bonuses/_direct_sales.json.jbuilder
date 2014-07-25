
json.entities \
  [ { bonus: bonus, data: bonus.requirements, partial: 'requirements' } ], 
  partial: 'entities', as: :entity

rank_range = Rank.rank_range

actions \
  action(:update, :patch, bonus_path(bonus)).
    field(:schedule, :select, options: Bonus::SCHEDULES, value: bonus.schedule).
    field(:amounts, :number, array: true, 
      first: rank_range ? rank_range.first : 0, 
      last: rank_range ? rank_range.last : 0),
  action(:delete, :delete, bonus_path(bonus))
