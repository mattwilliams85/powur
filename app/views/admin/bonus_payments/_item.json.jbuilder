klass :bonus_payment

json.properties do
  json.(bonus_payment, :pay_period_id, :amount, :name)
  json.user bonus_payment.user.full_name
end