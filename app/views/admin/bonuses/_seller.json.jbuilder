update = bonus_json.action(:update, :patch, bonus_path(bonus))
         .field(:name, :text, value: bonus.name)
         .field(:schedule, :select,
                options: Bonus.enum_options(:schedules),
                value:   bonus.schedule)
         .field(:first_n, :integer, value: bonus.first_n)
         .field(:first_n_amount, :decimal, value: bonus.first_n_amount)

actions update, action(:delete, :delete, bonus_path(bonus))
