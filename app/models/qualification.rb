class Qualification < ActiveRecord::Base

  belongs_to :rank
  belongs_to :product

  def type_string
    self.class.name.underscore.gsub(/_qualification/, '')
  end

  class << self
    def symbol_to_type(type_symbol)
      "#{type_symbol.to_s.split('_').map(&:capitalize).join}#{self.name}".constantize
    end
  end

end