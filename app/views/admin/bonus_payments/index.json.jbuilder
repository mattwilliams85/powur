siren json

klass :bonus_payments, :list

json.properties do
  json.totals do
    @totals.each do |key, value|
      json.set! key, number_to_currency(value)
    end
  end
end

json.entities @bonus_payments, partial: 'item', as: :bonus_payment

actions index_action(@bonus_payments_path)

links link(:self, @bonus_payments_path)
