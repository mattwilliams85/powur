klass :bonus_payment

json.properties do
  json.(bonus_payment, :pay_period_id, :created_at)
  json.amount Money.new(bonus_payment.amount).format
  json.(bonus_payment.bonus, :name)
  json.user bonus_payment.user.full_name
end