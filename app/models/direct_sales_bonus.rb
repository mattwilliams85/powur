class DirectSalesBonus < Bonus

  def percentages_used
    default_level.amounts
  end

end