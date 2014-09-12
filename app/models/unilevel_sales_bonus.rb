class UnilevelSalesBonus < Bonus
  include BonusEnums

  def last_bonus_level
    self.bonus_levels.count
  end

  def next_bonus_level
    last_bonus_level + 1
  end

  def percentage_used_by_levels(excluded_level = nil)
    levels = self.bonus_levels.entries
    levels.reject! { |l| l.level == excluded_level } if excluded_level
    levels.map(&:max).inject(:+) || 0.0
  end

  def create_payments!(order, pay_period)
    upline = order.user.parent_ids.reverse
    levels = bonus_levels.sort_by(&:level).reverse
    levels.each do |level|


    end
  end

end
