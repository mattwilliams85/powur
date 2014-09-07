class GroupSalesQualification < Qualification

  def percent_needed_for_smaller_legs
    (100.0 - self.max_leg_percent) * 0.01
  end

  def met?(totals, child_totals = nil)
    quantity_met?(totals) && max_leg_percent_met?(totals, child_totals)
  end

  def quantity_met?(totals)
    self.pay_period? ?
      totals.group >= self.quantity :
      totals.group_lifetime >= self.quantity
  end

  def max_leg_percent_met?(totals, child_totals = nil)
    return true if self.max_leg_percent.nil? || self.max_leg_percent.zero?
    child_totals ||= totals.pay_period.
      child_totals_for(totals.user_id, self.product_id)
    return false if child_totals.empty?

    quantities = self.pay_period? ?
      child_totals.map(&:group) : child_totals.map(&:group_lifetime)
    total_quantity = quantities.inject(:+)


    smaller_legs_total = total_quantity - quantities.max
    (BigDecimal.new(smaller_legs_total) / self.quantity) >= percent_needed_for_smaller_legs
  end
end
