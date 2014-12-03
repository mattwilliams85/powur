klass :bonus

json.rel [ :item ] unless local_assigns[:detail]

json.properties do
  json.call(bonus, :id, :name)
  json.schedule bonus.schedule.titleize
  json.use_rank_at bonus.use_rank_at.titleize
  if bonus.source?
    json.call(bonus, :available_amount)
  end
end

links link(:self, bonus_path(bonus))
