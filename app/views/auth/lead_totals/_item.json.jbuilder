klass :lead_totals

entity_rel

json.properties do
  json.call(lead_totals, :status)
  json.individual_month lead_totals.personal
  json.indvidual_lifetime lead_totals.personal_lifetime
  json.team_month lead_totals.team
  json.team_lifetime lead_totals.team_lifetime
end
