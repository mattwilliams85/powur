class GenerationalBonus < Bonus

  # def next_bonus_level
  #   (highest_bonus_level || 0) + 1
  # end

  # def remaining_percentages(max_rank)
  #   return super if bonus_levels.empty?

  #   [ other_product_percentages(max_rank), percentages_used(max_rank) ]
  #     .transpose.map { |i| i.reduce(:+) }
  #     .map { |percent| 1.0 - percent }
  # end

  # def remaining_percentages_for_level(level, max_rank = nil)
  #   levels = bonus_levels.select { |l| l.level == level }
  #   max_amounts = calculate_max_amounts(levels)
  #   remaining_percentages(max_rank).each_with_index.map do |a, i|
  #     subtracted = max_amounts[i]
  #     subtracted ? a + subtracted : a
  #   end
  # end

  # def create_payments!(order, pay_period)
  #   return unless order.user.parent?
  #   upline = pay_period.compressed_upline(order.user)
  #   return if upline.empty?

  #   bonus_levels.sort_by(&:level).group_by(&:level).each do |level, amounts|
  #     parent = find_qualified_parent(upline, amounts, pay_period)
  #     break if parent.nil?

  #     pay_parent(parent, level, pay_period, order)
  #   end
  # end

  # private

  # def parent_qualified?(parent, amounts, pay_period)
  #   pay_level = amounts.find do |level|
  #     level.rank_path_id.nil? || level.rank_path_id == parent.rank_path_id
  #   end
  #   pay_level && pay_period.find_pay_as_rank(parent) >= pay_level.min_rank
  # end

  # def find_qualified_parent(upline, amounts, pay_period)
  #   parent = nil
  #   loop do
  #     parent = upline.shift
  #     break if parent.nil? || parent_qualified?(parent, amounts, pay_period)
  #   end
  #   parent
  # end

  # def pay_parent(parent, level, pay_period, order)
  #   amount = payment_amount(parent.pay_as_rank,
  #                           parent.rank_path_id,
  #                           level)
  #   attrs = { bonus_id:    id,
  #             user_id:     parent.id,
  #             amount:      amount,
  #             pay_as_rank: parent.pay_as_rank }
  #   payment = pay_period.bonus_payments.create!(attrs)
  #   payment.bonus_payment_orders.create!(order_id: order.id)
  # end

end
