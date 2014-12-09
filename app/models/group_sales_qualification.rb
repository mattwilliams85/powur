class GroupSalesQualification < Qualification
  def percent_needed_for_smaller_legs
    (100.0 - max_leg_percent) * 0.01
  end

  def met?(totals, child_totals = nil)
    quantity_met?(totals) && max_leg_percent_met?(totals, child_totals)
  end

  def quantity_met?(totals)
    value = pay_period? ? totals.group : totals.group_lifetime
    value >= quantity
  end

  def max_leg_percent_met?(totals, child_totals = nil)
    return true if max_leg_percent.nil? || max_leg_percent.zero?
    child_totals ||= totals.pay_period.child_totals_for(
      totals.user_id, product_id)
    return false if child_totals.empty?

    smaller_legs = calculate_non_high_legs(child_totals)
    smaller_legs >= percent_needed_for_smaller_legs
  end

  private

  def totals_key
    pay_period? ? :group : :group_lifetime
  end

  def calculate_non_high_legs(child_totals)
    quantities = child_totals.map(&totals_key)
    total_quantity = quantities.inject(:+)

    smaller_legs_total = total_quantity - quantities.max
    BigDecimal.new(smaller_legs_total) / quantity
  end
end
