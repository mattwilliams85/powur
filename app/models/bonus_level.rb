class BonusLevel < ActiveRecord::Base
  belongs_to :bonus
  belongs_to :rank_path

  validates_presence_of :bonus_id, :level, :amounts

  def amounts=(value)
    write_attribute(:amounts, value.map(&:to_f))
  end

  def normalize_amounts(total)
    amounts.map { |a| a.is_a?(BigDecimal) ? a : BigDecimal.new(a.to_s) }
      .to_a.fill(BigDecimal('0'), (amounts.size...total))[0...total]
  end

  def filled_amounts(size)
    amounts.map.to_a.fill(BigDecimal('0'), (amounts.size...size))
  end

  def remaining_percentages(max_rank = nil)
    bonus.remaining_percentages_for_level(self.id, max_rank)
  end

  def all_paths?
    rank_path_id.nil?
  end

  def max(opts = {})
    return 0.0 if amounts.nil? || amounts.empty?
    start_index = opts[:min_rank] ? opts[:min_rank] - 1 : 0
    end_index = opts[:max_rank] || amounts.size
    amounts[start_index...end_index].max
  end

  def last?
    level == bonus.highest_bonus_level
  end

  def min_rank
    (amounts.index { |i| i > 0 } || amounts.size) + 1
  end

end
