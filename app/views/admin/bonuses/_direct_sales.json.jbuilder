
json.properties do
  json.amounts bonus.normalized_amounts.map(&:to_f)
end

bonus_json.item_entities

update = bonus_json.action(:update, :patch, bonus_path(bonus))
  .field(:name, :text, value: bonus.name)
  .field(:schedule, :select,
         options: Bonus.enum_options(:schedules),
         value:   bonus.schedule)
  .field(:use_rank_at, :select,
         options: Bonus.enum_options(:use_rank_ats),
         value:   bonus.use_rank_at)

bonus_json.amount_field(update, bonus) if bonus_json.can_add_level?(bonus)

actions update, action(:delete, :delete, bonus_path(bonus))
