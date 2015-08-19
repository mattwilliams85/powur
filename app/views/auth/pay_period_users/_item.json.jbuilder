klass :user

json.rel [ :item ] unless local_assigns[:detail]

json.properties do
  json.call(lead_totals.user, :id, :full_name)
  json.pay_as_rank lead_totals.user.pay_as_rank(@pay_period.id)
  json.force_rank lead_totals.user.override_rank(@pay_period.id)
  json.bonus_total @bonus_totals[lead_totals.user_id] || 0.0
  json.call(lead_totals, :personal, :personal_lifetime,
            :team, :team_lifetime, :smaller_legs)
end
