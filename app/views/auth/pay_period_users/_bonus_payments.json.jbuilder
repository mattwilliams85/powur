klass :bonus_payments, :list

entity_rel local_assigns[:rel]

json.entities bonus_payments,
              partial: 'auth/bonus_payments/item',
              as:      :bonus_payment

json.properties do
  json.grand_total @bonus_payments.sum(:amount)
end
