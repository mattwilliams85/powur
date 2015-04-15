klass :bonus_amounts, :list

json.entities bonus.bonus_amounts, partial: 'bonus_amount', as: :bonus_amount

if bonus_json.can_add_level?(bonus)
  actions bonus_json.create_amount_action(bonus)
end
