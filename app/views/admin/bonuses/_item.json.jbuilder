klass :bonus

json.rel [ :item ] unless local_assigns[:detail]

json.properties do
  json.(bonus, :id, :name)
  json.schedule bonus.schedule.titleize
end

links \
  link(:self, bonus_path(bonus))
