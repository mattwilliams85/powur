class PromoteOutBonus < Bonus
  include BonusEnums

  belongs_to :min_upline_rank, class_name: 'Rank'
  belongs_to :achieved_rank, class_name: 'Rank'

  def available_amount
    self.flat_amount || 0
  end

  def remaining_amount
    available_amount
  end

  def percentage_used
    0.0
  end

  def remaining_percentage
    1.0 - percentage_used
  end

end
