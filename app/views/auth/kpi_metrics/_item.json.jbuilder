klass :quotes_kpi

json.rel [ :item ] unless local_assigns[:detail]

json.properties do
  json.team_total #some_method
  json.period_id period
end

json.entities users_for_period(@contributor.downline_users, period), partial: 'entity', as: :user

