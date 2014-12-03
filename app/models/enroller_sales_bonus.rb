class EnrollerSalesBonus < Bonus
  belongs_to :max_user_rank, class_name: 'Rank'
  belongs_to :min_upline_rank, class_name: 'Rank'

  def percentages_used(max_rank)
    max = bonus_levels.map(&:amounts).flatten.max
    amounts = bonus_levels.map do |level|
      level.normalize_amounts(max_rank)
        .map { |a| a.zero? ? max : BigDecimal('0') }
    end
    return amounts.first if amounts.size == 1
    amounts.transpose.map(&:max)
  end

  def create_payments!(order, pay_period)
    return unless order.user.parent?

    parent = pay_period.find_upline_user(order.user.parent_id)

    return if parent_qualified?(parent, pay_period, order) || !compress
    while parent.parent?
      parent = pay_period.find_upline_user(parent.parent_id)
      break if parent_qualified?(parent, pay_period, order)
    end
  end

  private

  def parent_qualified?(parent, pay_period, order)
    return false unless pay_period.user_active?(parent.id)
    rank_id = pay_period.find_pay_as_rank(parent)
    return false if rank_id < min_upline_rank_id
    amount = 0#rank_amount(rank_id)
    attrs = {
      bonus_id:    id,
      user_id:     parent.id,
      amount:      amount,
      pay_as_rank: rank_id }
    payment = pay_period.bonus_payments.create!(attrs)
    payment.bonus_payment_orders.create!(order_id: order.id)
    true
  end
end
