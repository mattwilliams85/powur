class PayPeriod < ActiveRecord::Base

  before_create do
    self.id ||= self.class.id_from_date(self.start_date)
  end

  def calculated?
    !!self.calculated_at
  end

  def calculate!
    self.touch :calculated_at
  end

  class << self
    def generate_missing
      first_order = Order.order(order_date: :asc).first
      return unless first_order

      monthly_ids = MonthlyPayPeriod.ids_from(first_order.order_date)
      weekly_ids = WeeklyPayPeriod.ids_from(first_order.order_date)

      unless monthly_ids.empty?
        existing = MonthlyPayPeriod.where(id: monthly_ids).pluck(:id)
        monthly_ids -= existing
        monthly_ids.each { |id| MonthlyPayPeriod.create_from_id(id) }
      end
      unless weekly_ids.empty?
        existing = WeeklyPayPeriod.where(id: weekly_ids).pluck(:id)
        weekly_ids -= existing
        weekly_ids.each { |id| WeeklyPayPeriod.create_from_id(id) }
      end
    end
  end

end
