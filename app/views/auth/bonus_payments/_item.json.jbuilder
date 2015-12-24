klass :bonus_payment

entity_rel

json.properties do
  json.bonus bonus_payment.bonus.name
  json.call(bonus_payment, :id, :amount, :pay_period_id, :pay_as_rank, :status, :bonus_id)
  if (lead = bonus_payment.leads.first)
    json.lead do
      json.id lead.id
      json.converted_at lead.converted_at
      json.contracted_at lead.contracted_at
      json.installed_at lead.installed_at
      json.customer lead.full_name
      json.owner lead.user.full_name
    end
  end

end
