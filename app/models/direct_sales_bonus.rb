class DirectSalesBonus < Bonus
  include BonusEnums

  def percentages_used
    default_level.amounts
  end

end