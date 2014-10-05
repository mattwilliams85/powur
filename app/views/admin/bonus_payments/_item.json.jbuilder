klass :bonus_payment

json.properties do
  json.call(bonus_payment, :pay_period_id, :created_at)
  json.amount number_to_currency(bonus_payment.amount)
  json.call(bonus_payment.bonus, :name)
  json.bonus bonus_payment.bonus.name
  json.user bonus_payment.user.full_name
end
