class GroupSalesQualification < Qualification

  enum period: { pay_period: 1, lifetime: 2 }

  def percent_needed_for_smaller_legs
    (100.0 - self.max_leg_percent) * 0.01
  end

  def met?(user_id, pay_period)
    child_ids = pay_period.genealogy.select { |u| u.parent_id == user_id }.map(&:id)
    return false if child_ids.empty?

    child_totals = pay_period.order_totals.select do |t|
      t.product_id == self.product_id && child_ids.include?(t.user_id)
    end
    return false if child_totals.empty?
    quantities = self.pay_period? ? 
      child_totals.map(&:group) : child_totals.map(&:group_lifetime)
    total_quantity = quantities.inject(:+)

    return false unless total_quantity >= self.quantity

    return true if self.max_leg_percent.nil?

    smaller_legs_total = total_quantity - quantities.max
    (BigDecimal.new(smaller_legs_total) / self.quantity) >= percent_needed_for_smaller_legs
  end
end
