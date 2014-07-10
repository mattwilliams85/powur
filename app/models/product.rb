class Product < ActiveRecord::Base

  has_many :qualifications

  validates_presence_of :name, :bonus_volume, :commission_percentage

  class << self
    def default
      Product.find(SystemSettings.default_product_id)
    end
  end
end
