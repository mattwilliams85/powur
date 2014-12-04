klass :bonus

json.rel [ :item ] unless local_assigns[:detail]

json.properties do
  json.call(bonus, :id, :name)
  json.schedule bonus.schedule.titleize
  json.use_rank_at bonus.use_rank_at.titleize
  json.call(bonus, :available_amount) if bonus.source?
end

bonus_json.item_entities(bonus)

links link(:self, bonus_path(bonus))
