klass :bonus_payment

entity_rel

json.properties do
  json.bonus bonus_payment.bonus.name
  json.call(bonus_payment, :id, :amount, :pay_period_id, :pay_as_rank, :status)
  if (lead = bonus_payment.leads.first)
    json.lead do
      json.id lead.id
      json.customer lead.customer.full_name
      json.owner lead.user.full_name
    end
  end
  
end
