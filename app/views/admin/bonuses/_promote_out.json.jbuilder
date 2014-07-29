
json.properties do
  json.min_upline_rank bonus.min_upline_rank && bonus.min_upline_rank.title
  json.achieved_rank bonus.achieved_rank && bonus.achieved_rank.title
  json.(bonus, :compress, :flat_amount)
  json.amounts bonus.normalized_amounts
end

json.entities [], partial: 'entities', as: :entity

update = action(:update, :patch, bonus_path(bonus)).
  field(:name, :text, value: bonus.name).
  field(:schedule, :select, options: Bonus::SCHEDULES, value: bonus.schedule).
  field(:achieved_rank_id, :select,
    reference:  { type: :link, rel: :ranks, value: :id, name: :title }).
  field(:min_upline_rank_id, :select,
    reference:  { type: :link, rel: :ranks, value: :id, name: :title },
    value: bonus.min_upline_rank_id).
  field(:compress, :checkbox, value: bonus.compress).
  field(:flat_amount, :number, value: bonus.flat_amount)

update.amount_field(bonus) if bonus.can_add_amounts?

actions update, action(:delete, :delete, bonus_path(bonus))
