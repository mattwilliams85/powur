class Qualification < ActiveRecord::Base

  belongs_to :rank

  def type_string
    self.class.name.underscore.gsub(/_qualification/, '')
  end

  class << self
    def symbol_to_type(type_symbol)
      "#{type_symbol.to_s.capitalize}#{self.name}".constantize
    end
  end

end