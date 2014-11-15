klass :bonus_payment, :total

entity_rel :item

json.properties do
  json.call(bonus_payment, :amount)
  json.bonus bonus_payment.bonus.name
  %w(quantity).each do |field|
    if bonus_payment.attributes[field]
      json.set! field, bonus_payment.attributes[field]
    end
  end
end

self_link admin_user_bonus_payments_path(
  @user,
  pay_period: @pay_period,
  bonus:      bonus_payment.bonus_id)
