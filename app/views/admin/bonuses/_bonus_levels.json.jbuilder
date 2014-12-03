klass :bonus_levels, :list

json.entities bonus.bonus_levels, partial: 'bonus_level', as: :bonus_level

if bonus_json.can_add_level?(bonus)
  actions bonus_json.create_level_action(bonus)
end
