klass :bonus_plan

json.rel [ :item ] unless local_assigns[:detail]

json.properties do
  json.call(bonus_plan, :id, :name, :start_year, :start_month)
  json.active bonus_plan.active?
end

links link(:self, bonus_plan_path(bonus_plan))
