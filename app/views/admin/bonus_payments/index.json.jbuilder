siren json

klass :bonus_payments, :list

json.entities @bonus_payments, partial: 'item', as: :bonus_payment

actions index_action(@bonus_payments_path)

links link(:self, @bonus_payments_path)
