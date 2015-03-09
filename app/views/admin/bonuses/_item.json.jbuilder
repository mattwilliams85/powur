klass :bonus

json.rel [ :item ] unless local_assigns[:detail]

json.properties do
  json.call(bonus, :id, :name)
  json.schedule bonus.schedule.titleize
  if bonus.product
    json.available_amount bonus.product.commission_amount
  end
  bonus.meta_data_fields.key do |name|
    json.set! name, bonus.send(name)
  end
end

bonus_json.item_entities(bonus)

links link(:self, bonus_path(bonus))
