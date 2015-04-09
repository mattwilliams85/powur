update = bonus_json.action(:update, :patch, bonus_path(bonus))
         .field(:name, :text, value: bonus.name)
         .field(:schedule, :select,
                options: Bonus.enum_options(:schedules),
                value:   bonus.schedule)

actions update, action(:delete, :delete, bonus_path(bonus))
