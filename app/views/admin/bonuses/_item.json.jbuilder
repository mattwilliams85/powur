klass :bonus

json.rel [ :item ] unless local_assigns[:detail]

json.properties do
  json.call(bonus, :id, :name)
  json.schedule bonus.schedule.titleize
  if bonus.product
    json.available_amount bonus.product.commission_amount
  end

  (bonus.meta_data || {}).keys.each do |key|
    json.set! key, bonus.send(key)
  end
end

update = bonus_json.action(:update, :patch, bonus_path(bonus))
         .field(:name, :text, value: bonus.name)
         .field(:schedule, :select,
                options: Bonus.enum_options(:schedules),
                value:   bonus.schedule)
bonus.class.meta_data_fields.each do |key, type|
  update.field(key, type, value: bonus.send(key))
end

actions update, action(:delete, :delete, bonus_path(bonus))


links link(:self, bonus_path(bonus))
