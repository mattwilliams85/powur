
bonus_json.item_entities

update = bonus_json.action(:update, :patch, bonus_path(bonus))
  .field(:name, :text, value: bonus.name)
  .field(:schedule, :select,
         options: Bonus.enum_options(:schedules),
         value:   bonus.schedule)
  .field(:use_rank_at, :select,
         options: Bonus.enum_options(:use_rank_ats),
         value:   bonus.use_rank_at)

actions update, action(:delete, :delete, bonus_path(bonus))
