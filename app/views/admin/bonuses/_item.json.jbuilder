klass :bonus

json.rel [ :item ] unless local_assigns[:detail]

json.properties do
  json.(bonus, :id, :name, :compress)
  json.schedule bonus.schedule.titleize
  json.pays bonus.pays.titleize
  json.achieved_rank bonus.achieved_rank && bonus.achieved_rank.title
end

links \
  link(:self, bonus_path(bonus))
