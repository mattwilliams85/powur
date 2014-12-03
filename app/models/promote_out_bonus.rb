class PromoteOutBonus < Bonus
  belongs_to :min_upline_rank, class_name: 'Rank'
  belongs_to :achieved_rank, class_name: 'Rank'

  def available_amount
    flat_amount || 0
  end

  def remaining_amount
    available_amount
  end

  def remaining_percentages(max_rank)
    Array.new(max_rank, BigDecimal.new('1'))
  end

  def allows_many_requirements?
    true
  end
end
