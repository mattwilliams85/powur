class Product < ActiveRecord::Base

  has_many :qualifications

  validates_presence_of :name, :bonus_volume, :commission_percentage

  def total_bonus_allocation(exception_bonus_id = nil)
    query = Bonus.joins(:requirements).
      where(bonus_sales_requirements: { product_id: self.id, source: true })
    query = query.where.not(id: exception_bonus_id) if exception_bonus_id
    bonuses = query.entries
    bonuses.empty? ? 1.0 : bonuses.map(&:max_amount).inject(:+)
  end

  class << self
    def default
      Product.find(SystemSettings.default_product_id)
    end
  end
end
