class BonusLevel < ActiveRecord::Base

  self.primary_keys = :bonus_id, :level

  belongs_to :bonus

  validates_presence_of :bonus_id, :level, :amounts

  def max
    self.amounts.max
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
    bonus.remaining_percentage
  end

  def remaining_amount
    bonus.remaining_amount
  end
end
