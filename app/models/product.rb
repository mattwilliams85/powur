class Product < ActiveRecord::Base

  has_many :qualifications, dependent: :destroy
  has_many :bonus_sales_requirements, dependent: :destroy
  has_many :bonuses, through: :bonus_sales_requirements

  validates_presence_of :name, :bonus_volume, :commission_percentage

  def total_bonus_allocation(exception_bonus_id = nil)
    query = Bonus.joins(:requirements).
      where(bonus_sales_requirements: { product_id: self.id, source: true })
    query = query.where.not(id: exception_bonus_id) if exception_bonus_id
    bonuses = query.entries
    bonuses.empty? ? 0.0 : bonuses.map(&:max_amount).inject(:+)
  end

  def sale_bonuses
    @sale_bonuses ||= bonuses.select(&:sale?)
  end

  def has_sales_bonuses?
    !sales_bonuses.empty?
  end

  class << self
    def default
      Product.find(SystemSettings.default_product_id)
    end
  end
end
