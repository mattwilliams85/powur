class BonusLevel < ActiveRecord::Base

  self.primary_keys = :bonus_id, :level

  belongs_to :bonus

  validates_presence_of :bonus_id, :level, :amounts

  def amounts=(value)
    write_attribute(:amounts, value.map(&:to_f))
  end

  def normalized_amounts
    self.amounts.fill(0.0, (self.amounts.size...rank_range.last)).map(&:to_f)
  end

  def max
    self.amounts.max || 0.0
  end

  def rank_range
    @rank_range ||= self.bonus.rank_range ||
      ((self.amounts.empty? ? 0 : 1)..self.amounts.size)
  end

  def is_last?
    self.level == self.bonus.last_bonus_level
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

  private

  def percentage_used_by_other_levels
    @percentage_used_by_other_levels ||= bonus.percentage_used_by_levels(self.level)
  end

end
