
json.properties do
  json.max_user_rank bonus.max_user_rank && bonus.max_user_rank.title
  json.min_upline_rank bonus.min_upline_rank && bonus.min_upline_rank.title
  json.compress bonus.compress
end

json.entities \
  [ { bonus: bonus, data: bonus.requirements, partial: 'requirements' } ], 
  partial: 'entities', as: :entity

rank_range = Rank.rank_range

actions \
  action(:update, :patch, bonus_path(bonus)).
    field(:schedule, :select, options: Bonus::SCHEDULES, value: bonus.schedule).
    field(:max_user_rank_id, :select,
      reference:  { type: :link, rel: :ranks, value: :id, name: :title },
      value: bonus.max_user_rank_id).
    field(:min_upline_rank_id, :select,
      reference:  { type: :link, rel: :ranks, value: :id, name: :title },
      value: bonus.min_upline_rank_id).
    field(:compress, :checkbox, value: bonus.compress).
    field(:amounts, :number, array: true, 
      first: rank_range ? rank_range.first : 0, 
      last: rank_range ? rank_range.last : 0),
  action(:delete, :delete, bonus_path(bonus))
