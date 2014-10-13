class SystemSettings < RailsSettings::CachedSettings
  class << self
    def default_product
      Product.find(default_product_id)
    end
  end
end
