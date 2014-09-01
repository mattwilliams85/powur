klass :bonus

json.rel [ :item ] unless local_assigns[:detail]

json.properties do
  json.(bonus, :id, :name)
  json.schedule bonus.schedule.titleize
  json.use_rank_at bonus.use_rank_at.titleize
end

links \
  link(:self, bonus_path(bonus))
