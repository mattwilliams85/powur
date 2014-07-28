
json.properties do
  json.max_user_rank bonus.max_user_rank && bonus.max_user_rank.title
  json.min_upline_rank bonus.min_upline_rank && bonus.min_upline_rank.title
  json.(bonus, :compress, :amounts)
end

json.entities \
  [ { bonus: bonus, data: bonus.requirements, partial: 'requirements' } ], 
  partial: 'entities', as: :entity

update = action(:update, :patch, bonus_path(bonus)).
  field(:schedule, :select, options: Bonus::SCHEDULES, value: bonus.schedule).
  field(:max_user_rank_id, :select,
    reference:  { type: :link, rel: :ranks, value: :id, name: :title },
    value: bonus.max_user_rank_id).
  field(:min_upline_rank_id, :select,
    reference:  { type: :link, rel: :ranks, value: :id, name: :title },
    value: bonus.min_upline_rank_id).
  field(:compress, :checkbox, value: bonus.compress)

update.amount_field(bonus) if bonus.can_add_amounts?

actions update, action(:delete, :delete, bonus_path(bonus))
