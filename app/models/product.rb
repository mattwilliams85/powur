class Product < ActiveRecord::Base
  has_many :qualifications, dependent: :destroy
  has_many :bonus_sales_requirements, dependent: :destroy
  has_many :bonuses, through: :bonus_sales_requirements
  has_many :quote_fields, dependent: :destroy
  has_many :quote_field_lookups, through: :quote_fields

  validates_presence_of :name, :bonus_volume, :commission_percentage
  validates :commission_percentage, numericality: { less_than_or_equal_to: 100 }

  def sale_bonuses
    @sale_bonuses ||= bonuses.select { |b| b.sale? && b.enabled? }
  end

  def pay_period_end_bonuses
    @pay_period_end ||= bonuses.select { |b| b.pay_period_end? && b.enabled? }
  end

  def sales_bonuses?
    !sales_bonuses.empty?
  end

  def commission_amount
    bonus_volume * (0.01 * commission_percentage)
  end

  def quote_field_keys
    @quote_field_keys ||= quote_fields.map(&:name)
  end

  class << self
    def default_id
      SystemSettings.default_product_id
    end

    def default
      Product.find(default_id)
    rescue ActiveRecord::RecordNotFound
      product = Product.first
      SystemSettings.default_product_id = Product.first.id
      product
    end
  end
end
