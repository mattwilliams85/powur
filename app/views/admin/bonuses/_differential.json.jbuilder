
json.entities \
  [ { bonus: bonus, data: bonus.requirements, partial: 'requirements' },
    { bonus: bonus, data: bonus.bonus_levels, partial: 'bonus_levels' } ], 
  partial: 'entities', as: :entity

actions \
  update_action = action(:update, :patch, bonus_path(bonus)).
    field(:schedule, :select, options: Bonus::SCHEDULES, value: bonus.schedule).
    field(:max_user_rank_id, :select,
      reference:  { type: :link, rel: :ranks, value: :id, name: :title },
      value: @bonus.max_user_rank_id).
    field(:min_upline_rank_id, :select,
      reference:  { type: :link, rel: :ranks, value: :id, name: :title },
      value: @bonus.min_upline_rank_id)
    field(:compress, :checkbox, value: bonus.compress).
  action(:delete, :delete, bonus_path(bonus))
