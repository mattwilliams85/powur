class Qualification < ActiveRecord::Base

  belongs_to :rank
  belongs_to :product

  enum time_period: { lifetime: 1, monthly: 2, weekly: 3 }

  validates_presence_of :product_id, :quantity, :time_period

  TYPES =  { 
    sales:       'Personal Sales', 
    group_sales: 'Group Sales' }

  def type_string
    self.class.name.underscore.gsub(/_qualification/, '')
  end

  def type_display
    TYPES[type_string.to_sym]
  end

  def pay_period?
    self.monthly? || self.weekly?
  end

  class << self
    def symbol_to_type(type_symbol)
      "#{type_symbol.to_s.split('_').map(&:capitalize).join}#{self.name}".constantize
    end
  end

end
