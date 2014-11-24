class BonusLevel < ActiveRecord::Base
  belongs_to :bonus
  belongs_to :rank_path

  validates_presence_of :bonus_id, :level, :amounts

  def amounts=(value)
    write_attribute(:amounts, value.map(&:to_f))
  end

  def normalize_amounts(total)
    amounts.map.to_a.fill(BigDecimal('0'), (amounts.size...total))
  end

  def all_paths?
    rank_path_id.nil?
  end

  def max
    amounts.max || 0.0
  end

  def last?
    level == bonus.highest_bonus_level
  end

  def min_rank
    amounts.index { |i| i > 0 } + 1
  end

  private

  def percentage_used_by_other_levels
    @percentage_used_by_other_levels ||= bonus.percentage_used_by_levels(level)
  end
end
