class SystemSettings < RailsSettings::CachedSettings
  class << self
    def default_product
      Product.find(default_product_id)
    end

    # Returns value
    # forcing database call and cache rewrite
    def get!(key)
      record = object(key)
      return unless record
      record.rewrite_cache
      record.value
    end
  end
end
