klass :bonus_levels, :list

json.entities bonus_levels, partial: 'bonus_level', as: :bonus_level

if bonus.can_add_amounts?
  actions action(:create, :post, bonus_levels_path(bonus)).
    field(:amounts, :dollar_percentage, array: true,
      first: bonus.rank_range.first, last: bonus.rank_range.last,
      total: bonus.available_bonus_amount, max: bonus.available_bonus_percentage)
end


