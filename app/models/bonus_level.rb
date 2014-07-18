class BonusLevel < ActiveRecord::Base

  belongs_to :bonus

  validates_presence_of :bonus_id, :level, :amounts

end