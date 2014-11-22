class RankPath < ActiveRecord::Base
  has_many :qualifications, dependent: :destroy
  has_many :bonus_levels, dependent: :destroy

  validates_presence_of :name
end
