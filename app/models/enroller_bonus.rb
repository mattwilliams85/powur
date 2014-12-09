class EnrollerBonus < Bonus
  def percentages_used(max_rank)
    amounts = inversed_amounts(max_rank)
    amounts.size == 1 ? amounts.first : amounts.transpose.map(&:max)
  end

  def min_upline_rank
    @min_upline_rank ||= bonus_levels.map(&:min_rank).min || 1
  end

  def max_user_rank
    min_upline_rank - 1
  end

  def create_payments!(order, pay_period)
    return unless order.user.parent?
    user_rank = pay_period.find_pay_as_rank(order.user)
    return unless user_rank <= max_user_rank

    parent = pay_period.find_upline_user(order.user.parent_id)

    return if try_pay_parent(parent, pay_period, order) || !compress
    while parent.parent?
      parent = pay_period.find_upline_user(parent.parent_id)
      break if try_pay_parent(parent, pay_period, order)
    end
  end

  private

  def inversed_amounts(max_rank)
    max = bonus_levels.map(&:amounts).flatten.max
    bonus_levels.map do |level|
      level.normalize_amounts(max_rank).map do |a|
        a.zero? ? max : BigDecimal('0')
      end
    end
  end

  def try_pay_parent(parent, pay_period, order)
    return false unless pay_period.user_active?(parent)
    parent_rank = pay_period.find_pay_as_rank(parent)
    return false if parent_rank < min_upline_rank

    amount = payment_amount(parent_rank, parent.rank_path_id)
    attrs = { bonus_id:    id,
              user_id:     parent.id,
              amount:      amount,
              pay_as_rank: parent_rank }
    payment = pay_period.bonus_payments.create!(attrs)
    payment.bonus_payment_orders.create!(order_id: order.id)
    true
  end
end
