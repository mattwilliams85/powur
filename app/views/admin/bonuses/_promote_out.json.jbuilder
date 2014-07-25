
json.properties do
  json.achieved_rank bonus.achieved_rank && bonus.achieved_rank.title
  json.(bonus, :compress, :flat_amount)
end

json.entities [], partial: 'entities', as: :entity

actions \
  action(:update, :patch, bonus_path(bonus)).
    field(:schedule, :select, options: Bonus::SCHEDULES, value: bonus.schedule).
    field(:achieved_rank_id, :select,
      reference:  { type: :link, rel: :ranks, value: :id, name: :title }).
    field(:min_upline_rank_id, :select,
      reference:  { type: :link, rel: :ranks, value: :id, name: :title },
      value: bonus.min_upline_rank_id).
    field(:compress, :checkbox, value: bonus.compress).
    field(:flat_amount, :number, value: bonus.flat_amount),
  action(:delete, :delete, bonus_path(bonus))
