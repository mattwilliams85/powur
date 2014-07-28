klass :bonus_levels, :list

json.entities bonus_levels, partial: 'bonus_level', as: :bonus_level

if bonus.can_add_amounts?
  actions action(:create, :post, bonus_levels_path(bonus)).amount_field(bonus)
end