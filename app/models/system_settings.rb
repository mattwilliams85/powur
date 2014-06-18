class SystemSettings < RailsSettings::CachedSettings

  class << self
    def default_product
      Product.find(self.default_product_id)
    end
  end

end
