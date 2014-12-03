
json.properties do
  json.compress bonus.compress
end

bonus_json.item_entities

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
