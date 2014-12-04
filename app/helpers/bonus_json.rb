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
    amount_field(create_action, bonus.remaining_percentages(all_ranks.last.id))
    create_action
  end

  def update_level_action(bonus_level)
    update = action(:update, :patch, bonus_level_path(bonus_level))
    amount_field(update,
                 bonus_level.remaining_percentages(all_ranks.last.id),
                 bonus_level.normalize_amounts(all_ranks.size))
    update
  end

  def available_paths(bonus, level)
    path_ids = bonus.bonus_levels.select { |bl| bl.level == level }
      .map(&:rank_path_id)
    all_paths.reject { |p| path_ids.include?(p.id) }
  end

  def rank_path_field(action, bonus)
    # paths = available_paths(bonus)
    # return if paths.empty?
    options = Hash[all_paths.map { |p| [ p.id, p.name ] }]
    action.field(
      :rank_path_id, :select,
      options:  options = Hash[all_paths.map { |p| [ p.id, p.name ] }],
      required: false)
  end

  def amount_field(action, max_values, value = nil)
    attrs = {
      value_type: :dollar_percentage,
      size:       all_ranks.last.id,
      max_values: max_values }
    attrs[:value] = value
    action.field(:amounts, :array, attrs)
  end
end
