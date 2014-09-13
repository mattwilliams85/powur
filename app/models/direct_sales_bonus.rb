class DirectSalesBonus < Bonus

  def payment_amount(rank_id)
    source_product.commission_amount * normalized_amounts[rank_id - 1]
  end

  def create_payments!(order, pay_period)
    rank_id = pay_period.find_pay_as_rank(order.user)
    amount = payment_amount(rank_id)
    attrs = { 
      bonus_id:       self.id,
      user_id:        order.user_id,
      amount:         amount }
    payment = pay_period.bonus_payments.create!(attrs)
    payment.bonus_payment_orders.create!(order_id: order.id)
  end

end
