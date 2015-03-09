klass :bonus

json.rel [ :item ] unless local_assigns[:detail]

json.properties do
  json.call(bonus, :id, :name)
  json.schedule bonus.schedule.titleize
  if bonus.product
    json.available_amount bonus.product.commission_amount
  end
  bonus.meta_data_fields.keys do |name|
    json.set! name, bonus.send(name)
  end
end

bonus_json.item_entities(bonus)

update = bonus_json.action(:update, :patch, bonus_path(bonus))
         .field(:name, :text, value: bonus.name)
         .field(:schedule, :select,
                options: Bonus.enum_options(:schedules),
                value:   bonus.schedule)
bonus.meta_data_fields.each do |name, type|
  update.field(name, type, value: bonus.send(name))
end

actions update, action(:delete, :delete, bonus_path(bonus))


links link(:self, bonus_path(bonus))
