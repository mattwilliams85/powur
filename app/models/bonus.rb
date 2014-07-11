class Bonus < ActiveRecord::Base

  enum schedule: { weekly: 1, pay_period: 2 }
  validates_presence_of :type, :schedule

  def type_string
    self.class.name.underscore.gsub(/_bonus/, '')
  end

  def type_display
    I18n.t("bonuses.#{type_string}")
  end

  def schedule_display
    I18n.t("schedule.#{self.schedule}")
  end

  class << self
    def symbol_to_type(type_symbol)
      "#{type_symbol.to_s.split('_').map(&:capitalize).join}#{self.name}".constantize
    end
  end

end