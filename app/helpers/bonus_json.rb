class BonusJson < JsonDecorator
  def list_init(partial_path = 'item')
    klass :bonuses, :list

    list_entities(partial_path)
  end

  def item_entities(bonus = @item)
    entities entity('bonus_amounts', 'bonus-bonus_amounts', bonus: bonus)
  end

  def can_add_level?(bonus)
    !all_ranks.empty? && bonus.can_add_amounts?(all_paths.count)
  end

  def create_amount_action(bonus)
    create_action = action(:create, :post, bonus_amounts_path(bonus))
    rank_path_field(create_action, bonus)
    amount_field(create_action, bonus.remaining_amount)
    create_action
  end

  def update_amount_action(bonus_amount)
    update = action(:update, :patch, bonus_amount_path(bonus_amount))
    amount_field(update,
                 bonus_amount.bonus.remaining_amount,
                 bonus_amount.normalize_amounts(all_ranks.size))
    update
  end

  def available_paths(bonus, level)
    path_ids = bonus.bonus_levels.select { |bl| bl.level == level }
      .map(&:rank_path_id)
    all_paths.reject { |p| path_ids.include?(p.id) }
  end

  def rank_path_field(action, bonus)
    options = Hash[all_paths.map { |p| [ p.id, p.name ] }]
    action.field(
      :rank_path_id, :select,
      options:  options = Hash[all_paths.map { |p| [ p.id, p.name ] }],
      required: false)
  end

  def amount_field(action, max, value = nil)
    attrs = {
      value_type: :decimal,
      size:       all_ranks.last.id,
      max:        max }
    attrs[:value] = value
    action.field(:amounts, :array, attrs)
  end
end
