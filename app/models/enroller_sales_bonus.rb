class EnrollerSalesBonus < Bonus
  include BonusEnums

  belongs_to :max_user_rank, class_name: 'Rank'
  belongs_to :min_upline_rank, class_name: 'Rank'

  def create_payments!(order, pay_period)
    rank_id = pay_period.find_pay_as_rank(order.user)
    return if rank_id > max_user_rank_id
    
    
    # amount = payment_amount(rank_id)
    # attrs = { 
    #   bonus_id:       self.id,
    #   user_id:        order.user_id,
    #   amount:         amount }
    # payment = pay_period.bonus_payments.create!(attrs)
    # payment.bonus_payment_orders.create!(order_id: order.id)
  end

end
