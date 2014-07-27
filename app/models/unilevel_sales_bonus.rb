class UnilevelSalesBonus < Bonus

  def last_bonus_level
    self.bonus_levels.count
  end

  def next_bonus_level
    last_bonus_level + 1
  end

end