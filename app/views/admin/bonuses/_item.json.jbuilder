klass :bonus

json.rel [ :item ] unless local_assigns[:detail]

json.properties do
  json.(bonus, :id, :compress)
  json.schedule bonus.schedule.titleize
  json.achieved_rank bonus.achieved_rank && bonus.achieved_rank.title
end

links \
  link(:self, bonus_path(bonus))
