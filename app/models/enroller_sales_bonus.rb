class EnrollerSalesBonus < Bonus
  belongs_to :max_user_rank, class_name: 'Rank'
  belongs_to :min_upline_rank, class_name: 'Rank'

  def percentage_used
    other_bonuses = source_product.bonuses.reject { |b| b.id == id }

    amounts = other_bonuses.map do |bonus|
      if bonus.is_a?(DirectSalesBonus)
        bonus.default_level.amounts[max_user_rank_id - 1]
      else
        bonus.max_amount
      end
    end

    amounts.inject(:+)
  end

  def create_payments!(order, pay_period)
    return unless order.user.has_parent?

    parent = pay_period.find_upline_user(order.user.parent_id)

    return if parent_qualified?(parent, pay_period, order) || !compress
    while parent.has_parent?
      parent = pay_period.find_upline_user(parent.parent_id)
      break if parent_qualified?(parent, pay_period, order)
    end
  end

  private

  def parent_qualified?(parent, pay_period, order)
    return false unless pay_period.user_active?(parent.id)
    rank_id = pay_period.find_pay_as_rank(parent)
    return false if rank_id < min_upline_rank_id
    amount = rank_amount(rank_id)
    attrs = {
      bonus_id: id,
      user_id:  parent.id,
      amount:   amount }
    payment = pay_period.bonus_payments.create!(attrs)
    payment.bonus_payment_orders.create!(order_id: order.id)
    true
  end
end
