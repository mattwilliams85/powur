klass :bonus_levels, :list

json.entities bonus_levels, partial: 'bonus_level', as: :bonus_level

actions \
  action(:create, :post, bonus_levels_path(bonus))