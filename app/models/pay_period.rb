class PayPeriod < ActiveRecord::Base

  has_many :order_totals, dependent: :destroy

  before_create do
    self.id ||= self.class.id_from_date(self.start_date)
  end

  def calculable?
    Date.current > self.end_date
  end

  def calculated?
    !!self.calculated_at
  end

  def calculate!
    OrderTotal.generate_for_pay_period!(self)
    self.touch :calculated_at
  end

  def ranks
    @ranks ||= Rank.with_qualifications.entries
  end

  def group_order_totals
    Order.group_totals(self.start_date, self.end_date)
  end

  def personal_order_totals
    Order.personal_totals(self.start_date, self.end_date).entries
  end

  class << self
    def find_or_create_by_date(date)
      find_or_create_by_id(id_from(date.to_date))
    end

    def generate_missing
      first_order = Order.all_time_first
      return unless first_order

      [ MonthlyPayPeriod, WeeklyPayPeriod ].each do |period_klass|
        ids = period_klass.ids_from(first_order.order_date)
        unless ids.empty?
          existing = period_klass.where(id: ids).pluck(:id)
          ids -= existing
          ids.each { |id| period_klass.find_or_create_by_id(id) }
        end
      end
    end

    def find_or_create_by_id(id)
      klass = id.include?('W') ? WeeklyPayPeriod : MonthlyPayPeriod
      klass.find_or_create_by_id(id)
    end
  end

end
