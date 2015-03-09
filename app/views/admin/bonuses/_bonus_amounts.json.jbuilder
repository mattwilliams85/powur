klass :bonus_levels, :list

json.entities bonus.bonus_amounts, partial: 'bonus_amount', as: :bonus_amount

if bonus_json.can_add_level?(bonus)
  actions bonus_json.create_level_action(bonus)
end
