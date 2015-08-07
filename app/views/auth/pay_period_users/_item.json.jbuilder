klass :user

json.rel [ :item ] unless local_assigns[:detail]

json.properties do
  json.call(lead_totals.user, :id, :full_name)
  json.call(lead_totals, :personal, :personal_lifetime,
            :team, :team_lifetime, :smaller_legs)
end
