class Product < ActiveRecord::Base

  class << self
    def default
      Product.find(SystemSettings.default_product_id)
    end
  end
end
