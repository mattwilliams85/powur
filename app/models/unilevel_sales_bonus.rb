class UnilevelSalesBonus < Bonus

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

end