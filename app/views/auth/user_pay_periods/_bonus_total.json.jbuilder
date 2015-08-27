klass :bonus_total

entity_rel

json.properties do
  json.bonus bonus_total.bonus.name
  json.call(bonus_total, :bonus_total)
end
