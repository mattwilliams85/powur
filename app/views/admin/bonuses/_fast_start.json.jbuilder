bonus_json.item_entities

actions action(:update, :patch, bonus_path(bonus))
  .field(:name, :text, value: bonus.name)
  .field(:time_period, :select,
         options: t('enums.time_period'),
         value:   bonus.time_period)
  .field(:time_amount, :number, value: bonus.time_amount),
        action(:delete, :delete, bonus_path(bonus))
