class BonusLevel < ActiveRecord::Base
  self.primary_keys = :bonus_id, :level

  belongs_to :bonus

  validates_presence_of :bonus_id, :level, :amounts

  def amounts=(value)
    write_attribute(:amounts, value.map(&:to_f))
  end

  def normalized_amounts
    amounts.map.to_a.fill(BigDecimal('0'), (amounts.size...rank_range.last))
  end

  def max
    amounts.max || 0.0
  end

  def rank_range
    @rank_range ||= bonus.rank_range ||
      ((amounts.empty? ? 0 : 1)..amounts.size)
  end

  def last?
    level == bonus.last_bonus_level
  end

  def available_amount
    bonus.available_amount
  end

  def remaining_percentage
    bonus.remaining_percentage - percentage_used_by_other_levels
  end

  def remaining_amount
    available_amount * remaining_percentage
  end

  def min_rank
    amounts.index { |i| i > 0 } + 1
  end

  private

  def percentage_used_by_other_levels
    @percentage_used_by_other_levels ||= bonus.percentage_used_by_levels(level)
  end
end
