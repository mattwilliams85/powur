module TypedStoreAccessor
  extend ActiveSupport::Concern

  def typed_store_fields(field)
    attrs = self.class.typed_store_attributes
    attrs && attrs[field]
  end

  included do
    class << self
      attr_accessor :typed_store_attributes
    end
  end

  class_methods do
    def typed_store(store_attribute, key_types = {})
      args = [ store_attribute ] + key_types.keys
      store_accessor *args

      key_types.each do |key, type|
        case type
        when :integer
          define_method("#{key}=") do |value|
            super(value && value.to_i)
          end
          define_method(key) do
            value = super()
            value && value.to_i
          end
        when :money
          define_method("#{key}=") do |value|
            super(value && value.to_f.round(2))
          end
        when :date
          define_method("#{key}=") do |value|
            super(value && value.to_datetime)
          end
          define_method(key) do
            value = super()
            value && value.to_datetime
          end
        end
      end

      self.typed_store_attributes ||= {}
      self.typed_store_attributes[store_attribute] ||= {}
      self.typed_store_attributes[store_attribute]
        .merge!(key_types)
    end
  end
end
