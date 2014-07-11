klass :bonus

json.rel [ :item ] unless local_assigns[:detail]

json.properties do
  json.(bonus, :id)
  json.type bonus.type_display
  json.schedule bonus.pay_period.capitilize
end

links \
  link :self, bonus_path(bonus)