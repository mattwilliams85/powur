class BonusSalesRequirement < ActiveRecord::Base

  self.primary_keys = :bonus_id, :product_id

  belongs_to :bonus
  belongs_to :product

  validates_presence_of :bonus_id, :product_id

  def source_modifiable?
    bonus.allows_many_requirements? && source
  end
end
