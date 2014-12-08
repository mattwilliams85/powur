class Product < ActiveRecord::Base
  after_create :assign_sku

  has_many :qualifications, dependent: :destroy
  has_many :bonus_sales_requirements, dependent: :destroy
  has_many :bonuses, through: :bonus_sales_requirements
  has_many :quote_fields, dependent: :destroy
  has_many :quote_field_lookups, through: :quote_fields

  validates_presence_of :name, :bonus_volume, :commission_percentage
  validates :commission_percentage, numericality: { less_than_or_equal_to: 100 }

  scope :with_bonuses, -> { includes(bonuses: [ :bonus_levels ]) }

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

  def assign_sku
    self.sku = id.to_s.rjust(7, '0')
    save!
  end
  class << self
    def default_id
      SystemSettings.default_product_id
    end

    def default
      Product.find(default_id)
    rescue ActiveRecord::RecordNotFound
      if Product.any?
        product = Product.first
        SystemSettings.default_product_id = Product.first.id
      else
        product = false
      end
      product
    end
  end
end
