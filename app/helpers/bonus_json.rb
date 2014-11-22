class BonusJson < JsonDecorator
  def list_init(partial_path = 'item')
    klass :bonuses, :list

    list_entities(partial_path)
  end

  def item_entities(bonus = @item)
    entities entity('requirements', 'bonus-requirements', bonus: bonus),
             entity('bonus_levels', 'bonus-bonus_levels', bonus: bonus)
  end

  def can_add_level?(bonus)
    !all_ranks.empty? && bonus.can_add_amounts?(all_paths.count)
  end

  def create_level_action(bonus)
    create_action = action(:create, :post, bonus_levels_path(bonus))
    rank_path_field(create_action, bonus)
    amount_field(create_action, bonus)
    create_action
  end

  def update_level_action(bonus_level)
    update = action(:update, :patch, bonus_level_path(bonus_level))
    amount_field(update, bonus_level.bonus)
    update
  end

  def available_paths(bonus)
    path_ids = bonus.bonus_levels.map(&:rank_path_id)
    all_paths.reject { |p| path_ids.include?(p.id) }
  end

  def rank_path_field(action, bonus)
    paths = available_paths(bonus)
    return if paths.empty?
    action.field(
      :rank_path_id, :select,
      options:  Hash[paths.map { |p| [ p.id, p.name ] }],
      required: !bonus.bonus_levels.empty?)
  end

  def amount_field(action, bonus)
    action.field(
      :amounts, :dollar_percentage,
      array:     true,
      first:     bonus.rank_range.first,
      last:      bonus.rank_range.last,
      value:     bonus.normalized_amounts,
      total:     bonus.available_amount,
      remaining: bonus.remaining_amount,
      max:       bonus.remaining_percentage)
  end
end

