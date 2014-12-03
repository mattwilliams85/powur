class DirectSalesBonus < Bonus
  def create_payments!(order, pay_period)
    rank_id = pay_period.find_pay_as_rank(order.user)
    amount = payment_amount(rank_id, order.user.rank_path_id)
    attrs = {
      bonus_id:    id,
      user_id:     order.user_id,
      amount:      amount,
      pay_as_rank: rank_id}
    payment = pay_period.bonus_payments.create!(attrs)
    payment.bonus_payment_orders.create!(order_id: order.id)
  end
end
