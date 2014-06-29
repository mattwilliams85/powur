class Product < ActiveRecord::Base

  has_many :qualifications

  validates_presence_of :name, :commissionable_volume, :commission_percentage

  class << self
    def default
      Product.find(SystemSettings.default_product_id)
    end
  end
end
