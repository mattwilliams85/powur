class UnilevelSalesBonus < Bonus
  def sorted_levels
    @sorted_levels ||= bonus_levels.order(level: :asc)
  end

  def can_add_amounts?(_path_count = nil)
    source?
  end

  def next_bonus_level
    (highest_bonus_level || 0) + 1
  end

  def remaining_percentages(max_rank)
    return super if bonus_levels.empty?

    [ other_product_percentages(max_rank), percentages_used(max_rank) ]
      .transpose.map { |i| i.reduce(:+) }
      .map { |percent| 1.0 - percent }
  end

  def remaining_percentages_for_level(level, max_rank = nil)
    levels = bonus_levels.select { |l| l.level == level }
    max_amounts = calculate_max_amounts(levels)
    remaining_percentages(max_rank).each_with_index.map do |a, i|
      subtracted = max_amounts[i]
      subtracted ? a + subtracted : a
    end
  end

  def create_payments!(order, pay_period)
    return unless order.user.parent?
    upline = pay_period.compressed_upline(order.user)
    return if upline.empty?

    sorted_levels.each do |bonus_level|
      min_rank = bonus_level.min_rank
      parent = nil
      loop do
        parent = upline.shift
        break if parent.nil? || user_rank_met?(parent, min_rank, pay_period)
      end
      break if parent.nil?

      amount = payment_amount(bonus_level, parent.pay_as_rank)
      attrs = {
        bonus_id:    id,
        user_id:     parent.id,
        amount:      amount,
        pay_as_rank: parent.pay_as_rank }
      payment = pay_period.bonus_payments.create!(attrs)
      payment.bonus_payment_orders.create!(order_id: order.id)
    end
  end

  private

  def user_rank_met?(user, rank, pay_period)
    pay_period.find_pay_as_rank(user) >= rank
  end

  def payment_amount(bonus_level, rank)
    amount = bonus_level.amounts[rank - 1]
    amount ? amount * source_product.commission_amount : 0.0
  end
end
