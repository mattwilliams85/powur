
json.properties do
  json.min_upline_rank bonus.min_upline_rank && bonus.min_upline_rank.title
  json.achieved_rank bonus.achieved_rank && bonus.achieved_rank.title
  json.call(bonus, :compress, :flat_amount)
  json.amounts bonus.normalized_amounts
end

json.entities \
  [ { bonus: bonus, data: bonus.requirements, partial: 'requirements' } ],
  partial: 'entities', as: :entity

update = action(:update, :patch, bonus_path(bonus))
  .field(:name, :text, value: bonus.name)
  .field(:schedule, :select,
         options: Bonus.enum_options(:schedules),
         value:   bonus.schedule)
  .field(:use_rank_at, :select,
         options: Bonus.enum_options(:use_rank_ats),
         value:   bonus.use_rank_at)
  .field(:achieved_rank_id, :select,
         reference:  { type: :link, rel: :ranks, value: :id, name: :title })
  .field(:min_upline_rank_id, :select,
         reference: { type: :link, rel: :ranks, value: :id, name: :title },
         value:     bonus.min_upline_rank_id)
  .field(:compress, :checkbox, value: bonus.compress)
  .field(:flat_amount, :number, value: bonus.flat_amount)

update.amount_field(bonus) if bonus.can_add_amounts?

actions update, action(:delete, :delete, bonus_path(bonus))
