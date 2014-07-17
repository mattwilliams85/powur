class BonusSalesRequirement < ActiveRecord::Base

  belongs_to :bonus
  belongs_to :product

  validates_presence_of :bonus_id, :product_id

end