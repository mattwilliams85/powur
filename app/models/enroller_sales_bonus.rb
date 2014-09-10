class EnrollerSalesBonus < Bonus
  include BonusEnums

  belongs_to :max_user_rank, class_name: 'Rank'
  belongs_to :min_upline_rank, class_name: 'Rank'

  def create_payments!(order, pay_period)
    return unless order.user.has_parent?
    rank_id = pay_period.find_pay_as_rank(order.user)
    return if rank_id > max_user_rank_id

    parent = pay_period.find_upline_user(order.user.parent_id)
    if !parent_qualified?(parent, pay_period, order) && self.compress
      while parent.has_parent? do
        parent = pay_period.find_upline_user(parent.parent_id)
        break if parent_qualified?(parent, pay_period, order)
      end
    end
  end

  private

  def parent_qualified?(parent, pay_period, order)
    rank_id = pay_period.find_pay_as_rank(parent)
    return false if rank_id < min_upline_rank_id
    amount = rank_amount(rank_id)
    attrs = {
      bonus_id: self.id,
      user_id:  parent.id,
      amount:   amount }
    payment = pay_period.bonus_payments.create!(attrs)
    payment.bonus_payment_orders.create!(order_id: order.id)
    true
  end

end
