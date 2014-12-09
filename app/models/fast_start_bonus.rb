class FastStartBonus < Bonus
  TIME_PERIODS = %w(days months years)

  store_accessor :meta_data, :time_period, :time_amount

  validates :time_period, inclusion: { in: TIME_PERIODS }, allow_nil: true
  validates :time_amount,
            numericality: { only_integer: true, greater_than: 0 },
            allow_nil:    true

  def time_amount_int
    time_amount.presence && time_amount.to_i
  end

  def quantity_int
    quantity.to_int
  end

  def create_payments!(order, pay_period)
    return unless qualified_in_time?(order)
    totals = pay_period.find_order_total(order.user_id, order.product_id)
    return unless qualified_for_quantity?(totals)

    rank_id = pay_period.find_pay_as_rank(order.user)
    amount = payment_amount(rank_id, order.user.rank_path_id)

    attrs = {
      bonus_id:    id,
      user_id:     order.user_id,
      amount:      amount,
      pay_as_rank: rank_id }
    payment = pay_period.bonus_payments.create!(attrs)
    payment.bonus_payment_orders.create!(order_id: order.id)
  end

  def qualified_in_time?(order)
    (order.order_date.to_i - order.user.created_at.to_i) < time_span
  end

  def qualified_for_quantity?(totals)
     totals.personal_lifetime == source_requirement.quantity
  end

  def time_span
    time_amount_int.send(time_period)
  end
end
