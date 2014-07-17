class Qualification < ActiveRecord::Base

  belongs_to :rank
  belongs_to :product

  TYPES =  { 
    sales:       'Personal Sales', 
    group_sales: 'Group Sales' }
  PERIODS = { 
    pay_period: 'Pay Period', 
    lifetime:   'Lifetime' }

  def type_string
    self.class.name.underscore.gsub(/_qualification/, '')
  end

  def type_display
    TYPES[type_string.to_sym]
  end

  class << self
    def symbol_to_type(type_symbol)
      "#{type_symbol.to_s.split('_').map(&:capitalize).join}#{self.name}".constantize
    end
  end

end