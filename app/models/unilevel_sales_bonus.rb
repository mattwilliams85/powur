class UnilevelSalesBonus < Bonus
  def last_bonus_level
    bonus_levels.count
  end

  def next_bonus_level
    last_bonus_level + 1
  end

  def percentage_used_by_levels(excluded_level = nil)
    levels = bonus_levels.entries
    levels.reject! { |l| l.level == excluded_level } if excluded_level
    levels.map(&:max).inject(:+) || 0.0
  end

  def sorted_levels
    @sorted_levels ||= bonus_levels.order(level: :asc)
  end

  def create_payments!(order, pay_period)
    return unless order.user.has_parent?
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
